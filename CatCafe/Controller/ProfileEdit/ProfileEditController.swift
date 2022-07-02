//
//  ProfileEditController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import Foundation
import UIKit
import ProgressHUD
import RxSwift
import RxCocoa
import FirebaseAuth

class ProfileEditController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private var hasChangedImage = false

    var user: User?
    
    private var username = ""
    private var fullname = ""
    private var email = ""
    
    let leaveButton = makeIconButton(imagename: "Icons_24px_Close",
                                     imageColor: .white,
                                     imageWidth: 20, imageHeight: 20,
                                     backgroundColor: .darkGray,
                                     cornerRadius: 36 / 2)
    
    let profileEditButton = makeProfileEditButton()
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no-Image")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 120/2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let titleLabel = ProfileLabel()
    
    lazy var colletionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.register(
            InfoCollectionViewCell.self,
            forCellWithReuseIdentifier: InfoCollectionViewCell.identifier
        )
        return collectionView
    }()
    
    let saveButton = makeTitleButton(withText: "儲存",
                                     font: .systemFont(ofSize: 17, weight: .regular),
                                     kern: 0.8,
                                     foregroundColor: .white,
                                     backgroundColor: .systemBrown,
                                     insets: .init(top: 5, left: 10, bottom: 5, right: 10),
                                     cornerRadius: 8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
    }
}

extension ProfileEditController {
    func setup() {
        // 傳過來的 user 取其中的 profileImageUrl，顯示
        if let url = URL(string: user?.profileImageUrlString ?? "") {
            profileImageView.sd_setImage(with: url)
        }
        // 傳過來的 user 取其中的 name，顯示
        titleLabel.text = user?.fullname

        leaveButton.addTarget(self, action: #selector(handleLeave), for: .touchUpInside)
        profileEditButton.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    func style() {
        view.backgroundColor = .white
        leaveButton.layer.cornerRadius = 36 / 2
        leaveButton.clipsToBounds = true
    }
    
    func layout() {
        view.addSubview(leaveButton)
        view.addSubview(titleLabel)
        view.addSubview(profileImageView)
        view.addSubview(profileEditButton)
        view.addSubview(colletionView)
        view.addSubview(saveButton)
        
        leaveButton.anchor(top: view.topAnchor,
                           left: view.leftAnchor,
                           paddingTop: 56, paddingLeft: 24)
        leaveButton.setDimensions(height: 36, width: 36)
        
        profileImageView.anchor(top: view.topAnchor, paddingTop: 80)
        profileImageView.centerX(inView: view)
        profileImageView.setDimensions(height: 120, width: 120)
        
        titleLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 20)
        titleLabel.centerX(inView: view)
        
        profileEditButton.anchor(top: profileImageView.topAnchor,
                                 right: profileImageView.rightAnchor,
                                 width: 36, height: 36)
        
        colletionView.anchor(top: titleLabel.bottomAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 32,
                             paddingLeft: 40, paddingRight: 40)
        colletionView.setHeight(250)
        colletionView.backgroundColor = .clear
        
        saveButton.anchor(top: colletionView.bottomAnchor, paddingTop: 30)
        saveButton.centerX(inView: colletionView)
        saveButton.setDimensions(height: 40, width: 80)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileEditController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = colletionView.dequeueReusableCell(
            withReuseIdentifier: InfoCollectionViewCell.identifier,
            for: indexPath
        ) as? InfoCollectionViewCell else { return UICollectionViewCell() }
        cell.user = self.user // user 傳給 cell 的user
        setupCellBindings(cell: cell) // 把編輯的內容與同步到 self 的屬性
        return cell
    }

    private func setupCellBindings(cell: InfoCollectionViewCell) {
        cell.usernameTextField.rx.text
            .asDriver()
            .drive { [weak self] text in
                self?.username = text ?? ""
            }
            .disposed(by: disposeBag)

        cell.fullnameTextField.rx.text
            .asDriver()
            .drive { [weak self] text in
                self?.fullname = text ?? ""
            }
            .disposed(by: disposeBag)
        
        cell.emailTextField.rx.text
            .asDriver()
            .drive { [weak self] text in
                self?.email = text ?? ""
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions
extension ProfileEditController {
    
    @objc func handleLeave() {
        dismiss(animated: false)
    }
    
    // 點選儲存按鈕（上傳）
    @objc func saveButtonTapped() {
        let alert = UIAlertController(title: "確定送出？", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            
            let group = DispatchGroup()
            
            group.enter()
            CCProgressHUD.show()
            UserService.shared.updateCurrentUserInfo(
                fullname: self.fullname,
                username: self.username,
                email: self.email
            ) { error in
                CCProgressHUD.dismiss()
                
                if let error = error {
                    CCProgressHUD.showFailure()
                    print("DEBUG: Failed to create profile with error: \(error.localizedDescription)")
                    return
                }
                
                CCProgressHUD.showSuccess(text: "資料已更新")
                self.titleLabel.text = self.fullname
                
                group.leave()
            }
        
            if self.hasChangedImage {
                guard let profileImage = self.profileImageView.image else {
                    self.showMessage(withTitle: "請上傳大頭照", message: nil)
                    return
                }
                
                guard let currentUid = LocalStorage.shared.getUid() else { return }
                let directory = "Profile/" + "_\(currentUid)" + ".jpg"
                
                ProgressHUD.show()
                
                group.enter()
                FileStorage.uploadImage(profileImage, directory: directory) { profileImageUrlString in
                    
                    CCProgressHUD.show()
                    UserService.shared.uploadProfileImage(
                        userId: currentUid,
                        profileImageUrlString: profileImageUrlString
                    ) { error in
                        CCProgressHUD.dismiss()
                        
                        if let error = error {
                            CCProgressHUD.showFailure()
                            print("DEBUG: Failed to create imageUrlString with error: \(error.localizedDescription)")
                            return
                        }
                        
                        CCProgressHUD.showSuccess(text: "頭貼已更新")
                        
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                // Call Tab bar controller to refetch current user
                NotificationCenter.default.post(name: CCConstant.NotificationName.updateProfile, object: nil)
            }
        }
        
        okAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in }
        cancelAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // 按頭貼編輯按鈕
    @objc func profileEditButtonTapped() {
        let actionSheet = UIAlertController(title: "Add a Photo",
                                            message: "Select a source:",
                                            preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Camera", style: .default) { _ in
                self.showImagePickerController(mode: .camera)
            }
            actionSheet.addAction(cameraButton)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryButton = UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.showImagePickerController(mode: .photoLibrary)
            }
            actionSheet.addAction(libraryButton)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func showImagePickerController(mode: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = mode
        present(picker, animated: true, completion: nil)
    }

}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProfileEditController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else { return }
        profileImageView.image = image.withRenderingMode(.alwaysOriginal)
        self.hasChangedImage = true
        
        picker.dismiss(animated: true)
    }
}
