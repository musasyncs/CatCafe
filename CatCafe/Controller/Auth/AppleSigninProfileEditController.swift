//
//  AppleSigninProfileEditController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/11.
//

import UIKit
import ProgressHUD
import FirebaseAuth

class AppleSigninProfileEditController: UIViewController {
    
    private var hasChangedImage = false
    
    // MARK: - View
    private let saveButton = makeIconButton(
        imagename: ImageAsset.check.rawValue,
        imageColor: .ccPrimary,
        imageWidth: 28,
        imageHeight: 28
    )
    
    private let profileEditButton = makeProfileEditButton()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.asset(.no_image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 96 / 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel = makeLabel(
        withTitle: "",
        font: .systemFont(ofSize: 20, weight: .bold),
        textColor: .ccGrey
    )
    
    private let usernameLabel = makeLabel(
        withTitle: "帳號",
        font: .systemFont(ofSize: 13, weight: .regular),
        textColor: .ccGrey
    )
    private let fullnameLabel = makeLabel(
        withTitle: "全名",
        font: .systemFont(ofSize: 13, weight: .regular),
        textColor: .ccGrey
    )
    private let bioLabel = makeLabel(
        withTitle: "個人簡介（至多34字）",
        font: .systemFont(ofSize: 13, weight: .regular),
        textColor: .ccGrey
    )
    private let usernameTextField = ProfileTextField(placeholder: "請輸入帳號")
    private let fullnameTextField = ProfileTextField(placeholder: "請輸入全名")
    lazy var bioTextView: InputTextView = {
        let textView = InputTextView()
        textView.delegate = self
        textView.backgroundColor = .ccGreyVariant.withAlphaComponent(0.1)
        textView.layer.cornerRadius = 5
        return textView
    }()

    private lazy var stackView = UIStackView()
    private lazy var bioStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
        
        setupNotificationObservers()
    }
    
    // MARK: - Action
    @objc func keyboardWillShow(notification: NSNotification) {
        let distance = CGFloat(100)
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.view.transform = transform
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.view.transform = .identity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension AppleSigninProfileEditController {
    
    private func setup() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        profileEditButton.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
    }
    
    private func style() {
        view.backgroundColor = .white
        nameLabel.textAlignment = .center
        
        let pairs = [
            [usernameLabel, usernameTextField],
            [fullnameLabel, fullnameTextField]
        ]
        let pairSVs = pairs.map { (pair) -> UIStackView in
            guard let label = pair.first as? UILabel,
                  let textField = pair.last as? UITextField else { return UIStackView() }
            let pairSV = UIStackView(arrangedSubviews: [label, textField])
            pairSV.axis = .vertical
            pairSV.spacing = 5
            textField.textColor = .ccGrey
            textField.anchor(height: 45)
            return pairSV
        }
        stackView = UIStackView(arrangedSubviews: pairSVs)
        stackView.axis = .vertical
        stackView.spacing = 15
        
        bioStackView = UIStackView(arrangedSubviews: [bioLabel, bioTextView])
        bioStackView.axis = .vertical
        bioStackView.spacing = 5
    }
    
    private func layout() {
        view.addSubview(saveButton)
        view.addSubview(nameLabel)
        view.addSubview(profileImageView)
        view.addSubview(profileEditButton)
        view.addSubview(stackView)
        view.addSubview(bioStackView)
 
        saveButton.anchor(
            top: view.topAnchor,
            right: view.rightAnchor,
            paddingTop: 56, paddingRight: 24
        )
        saveButton.setDimensions(height: 36, width: 36)
        
        profileImageView.anchor(top: view.topAnchor, paddingTop: 96)
        profileImageView.centerX(inView: view)
        profileImageView.setDimensions(height: 96, width: 96)
        
        profileEditButton.anchor(
            top: profileImageView.topAnchor,
            right: profileImageView.rightAnchor,
            paddingTop: -4, paddingRight: -4,
            width: 28, height: 28
        )
        
        nameLabel.anchor(
            top: profileImageView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20,
            paddingLeft: 24,
            paddingRight: 24
        )
        nameLabel.centerX(inView: view)
    
        stackView.anchor(
            top: nameLabel.bottomAnchor,
            paddingTop: 28,
            width: UIScreen.width * 0.7
        )
        stackView.centerX(inView: view)
        
        bioStackView.anchor(
            top: stackView.bottomAnchor,
            paddingTop: 15,
            width: UIScreen.width * 0.7
        )
        bioStackView.centerX(inView: view)
        bioTextView.setHeight(60)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
}

// MARK: - Actions
extension AppleSigninProfileEditController {
    
    @objc func handleLeave() {
        dismiss(animated: false)
    }
    
    // 點選儲存按鈕（上傳）
    // swiftlint:disable all
    @objc func saveButtonTapped() {
        let alert = UIAlertController(title: "確定送出？", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            guard let username = self.usernameTextField.text,
                  !username.isEmpty else {
                self.showMessage(withTitle: "Oops", message: "帳號不可為空")
                return
            }
            
            guard let fullname = self.fullnameTextField.text,
                  !fullname.isEmpty else {
                self.showMessage(withTitle: "Oops", message: "全名不可為空")
                return
            }
            
            guard let bioText = self.bioTextView.text else { return }
            
            let group = DispatchGroup()
            
            group.enter()
            self.show()
            UserService.shared.updateCurrentUserInfo(
                fullname: fullname,
                username: username,
                bioText: bioText
            ) { error in
                
                if error != nil {
                    self.dismiss()
                    self.showFailure(text: "無法更新個人資料")
                    return
                }
                
                self.dismiss()
                self.showSuccess(text: "資料已更新")
                self.nameLabel.text = fullname
                
                group.leave()
            }
        
            group.enter()
            self.show()
            guard let profileImage = self.profileImageView.image else {
                self.showMessage(withTitle: "請上傳大頭照", message: nil)
                return
            }
            guard let currentUid = LocalStorage.shared.getUid() else { return }
            let directory = "Profile/" + "_\(currentUid)" + ".jpg"
            
            FileStorage.uploadImage(profileImage, directory: directory) { profileImageUrlString in
                
                UserService.shared.uploadProfileImage(
                    userId: currentUid,
                    profileImageUrlString: profileImageUrlString
                ) { error in
                    
                    if error != nil {
                        self.dismiss()
                        self.showFailure(text: "無法更新頭貼")
                        return
                    }
                    self.dismiss()
                    self.showSuccess(text: "頭貼已更新")
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.dismiss(animated: true)
            }
        }
        
        okAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in }
        cancelAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    // swiftlint:enable all
    
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
extension AppleSigninProfileEditController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
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

// MARK: - UITextViewDelegate
extension AppleSigninProfileEditController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxlength(textView)
    }
    
    private func checkMaxlength(_ textView: UITextView) {
        if textView.text.count > 34 {
            textView.deleteBackward()
        }
    }
}
