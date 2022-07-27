//
//  ProfileEditController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import UIKit
import ProgressHUD
import FirebaseAuth

class ProfileEditController: UIViewController {
    
    private var hasChangedImage = false

    var user: User? {
        didSet {
            nameLabel.text = user?.fullname
            
            usernameTextField.text = user?.username
            fullnameTextField.text = user?.fullname
            bioTextView.text = user?.bioText
        }
    }
    
    // MARK: - View
    private let leaveButton = makeIconButton(
        imagename: ImageAsset.Icons_24px_Close.rawValue,
        imageColor: .white,
        imageWidth: 20, imageHeight: 20,
        backgroundColor: .ccGrey,
        cornerRadius: 36 / 2
    )
    
    private let saveButton = makeIconButton(
        imagename: ImageAsset.check.rawValue,
        imageColor: .ccPrimary,
        imageWidth: 28,
        imageHeight: 28
    )
    
    private let profileEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            SFSymbols.square_pencil?.resize(to: .init(width: 20, height: 20)),
            for: .normal
        )
        button.imageView?.contentMode = .scaleToFill
        
        button.layer.cornerRadius = 28/2
        button.layer.borderWidth = 0.3
        button.layer.borderColor = UIColor.darkGray.cgColor
        
        button.backgroundColor = .white
        button.tintColor = .darkGray
        return button
    }()
    
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
        withTitle: "個人簡介（至多34字元）",
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
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1, options: []
        ) { [weak self] in
            self?.view.transform = transform
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: []
        ) { [weak self] in
            self?.view.transform = .identity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension ProfileEditController {
    
    private func setup() {
        leaveButton.addTarget(self, action: #selector(handleLeave), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        profileImageView.loadImage(user?.profileImageUrlString)
        profileEditButton.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
    }
    
    private func style() {
        view.backgroundColor = .white
        leaveButton.layer.cornerRadius = 36 / 2
        leaveButton.clipsToBounds = true
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
    
    // swiftlint:disable all
    private func layout() {
        view.addSubviews(leaveButton, saveButton, nameLabel, profileImageView, profileEditButton, stackView, bioStackView)
        
        leaveButton.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            paddingTop: 56, paddingLeft: 24
        )
        leaveButton.setDimensions(height: 36, width: 36)
        
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
            width: ScreenSize.width * 0.7
        )
        stackView.centerX(inView: view)
        
        bioStackView.anchor(
            top: stackView.bottomAnchor,
            paddingTop: 15,
            width: ScreenSize.width * 0.7
        )
        bioStackView.centerX(inView: view)
        bioTextView.setHeight(60)
    }
    // swiftlint:enable all
    
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
extension ProfileEditController {
    
    @objc func handleLeave() {
        dismiss(animated: false)
    }
    
    // 點選儲存按鈕（上傳）
    // swiftlint:disable all
    @objc func saveButtonTapped() {
        let alert = UIAlertController(title: "確定送出？", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let username = self.usernameTextField.text,
                  !username.isEmpty else {
                AlertHelper.showMessage(title: "Oops", message: "帳號不可為空", buttonTitle: "OK", over: self)
                return
            }
            
            guard let fullname = self.fullnameTextField.text,
                  !fullname.isEmpty else {
                AlertHelper.showMessage(title: "Oops", message: "全名不可為空", buttonTitle: "OK", over: self)
                return
            }
            
            guard let bioText = self.bioTextView.text else { return }
            
            let group = DispatchGroup()
            
            group.enter()
            UserService.shared.updateCurrentUserInfo(
                fullname: fullname,
                username: username,
                bioText: bioText
            ) { [weak self] error in
                guard let self = self else { return }
                
                if error != nil {
                    self.showFailure(text: "失敗")
                    return
                }
                
                self.nameLabel.text = fullname
                
                group.leave()
            }
        
            if self.hasChangedImage {
                guard let profileImage = self.profileImageView.image else {
                    AlertHelper.showMessage(title: "請上傳大頭照", message: "", buttonTitle: "OK", over: self)
                    return
                }
                
                guard let currentUid = LocalStorage.shared.getUid() else { return }
                let directory = "Profile/" + "_\(currentUid)" + ".jpg"
                
                group.enter()
                FileStorage.uploadImage(profileImage, directory: directory) { profileImageUrlString in
                    
                    UserService.shared.uploadProfileImage(
                        userId: currentUid,
                        profileImageUrlString: profileImageUrlString
                    ) { [weak self] error in
                        guard let self = self else { return }
                        
                        if error != nil {
                            self.showFailure(text: "無法更新頭貼")
                            return
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                // Call Tab bar controller to refetch current user
                NotificationCenter.default.post(name: CCConstant.NotificationName.updateProfile, object: nil)
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
            let cameraButton = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.showImagePickerController(mode: .camera)
            }
            actionSheet.addAction(cameraButton)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryButton = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                guard let self = self else { return }
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

// MARK: - UITextViewDelegate
extension ProfileEditController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxlength(textView)
    }
    
    private func checkMaxlength(_ textView: UITextView) {
        if textView.text.count > 34 {
            textView.deleteBackward()
        }
    }
}

// MARK: - ProfileTextField
class ProfileTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        borderStyle = .roundedRect
        backgroundColor = .ccGreyVariant.withAlphaComponent(0.1)
        font = .systemFont(ofSize: 14, weight: .regular)
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray2,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)
            ]
        )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
