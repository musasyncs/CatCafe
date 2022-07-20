//
//  SetProfileController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import UIKit
import ProgressHUD

class SetProfilePictureController: UIViewController {
        
    private var profileImage: UIImage?
    
    // MARK: - Views
    private let plusPhotoButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
   
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPlusPhotoButton()
        setupSendButton()
    }
    
    // MARK: - Action
    @objc func handleProfilePhotoSelect() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc func sendProfileImage() {
        guard let profileImage = profileImage else {
            AlertHelper.showMessage(title: "Validate Failed", message: "請上傳大頭照", buttonTitle: "OK", over: self)
            return
        }
        
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        let directory = "Profile/" + "_\(currentUid)" + ".jpg"
        
        ProgressHUD.show()
        FileStorage.uploadImage(profileImage, directory: directory) { imageUrlString in
            
            UserService.shared.uploadProfileImage(
                userId: currentUid,
                profileImageUrlString: imageUrlString
            ) { [weak self] error in
                guard let self = self else { return }
                
                if error != nil {
                    self.showFailure(text: "Failed to create profile image")
                    return
                }
                
                self.dismiss(animated: true)
            }
        }
    }

}

extension SetProfilePictureController {
    
    private func setupPlusPhotoButton() {
        plusPhotoButton.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        plusPhotoButton.setImage(UIImage.asset(.plus_photo), for: .normal)
        plusPhotoButton.tintColor = .lightGray
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        view.addSubview(plusPhotoButton)
        plusPhotoButton.center(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
    }
    
    private func setupSendButton() {
        sendButton.addTarget(self, action: #selector(sendProfileImage), for: .touchUpInside)
        sendButton.setTitle("送出", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 5
        sendButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        sendButton.backgroundColor = .ccPrimary
        view.addSubview(sendButton)
        sendButton.setDimensions(height: 36, width: 80)
        sendButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 80)
        sendButton.centerX(inView: view)
    }

}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SetProfilePictureController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        profileImage = selectedImage

        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        self.dismiss(animated: true)
    }
}
