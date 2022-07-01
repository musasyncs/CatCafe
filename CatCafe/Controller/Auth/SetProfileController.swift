//
//  SetProfileController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import UIKit
import ProgressHUD

class SetProfileController: UIViewController {
        
    private var profileImage: UIImage?

    private let plusPhotoButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
    }
    
    // MARK: - Action
    @objc func handleProfilePhotoSelect() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func sendProfileImage() {
        guard let profileImage = profileImage else {
            showMessage(withTitle: "Validate Failed", message: "請上傳大頭照")
            return
        }
        
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        let directory = "Profile/" + "_\(currentUid)" + ".jpg"
        
        ProgressHUD.show()
        FileStorage.uploadImage(profileImage, directory: directory) { imageUrlString in
            
            CCProgressHUD.show()
            UserService.shared.uploadProfileImage(
                userId: currentUid,
                profileImageUrlString: imageUrlString
            ) {error in
                CCProgressHUD.dismiss()
                
                if let error = error {
                    print("DEBUG: Failed to create profile image urlString with error: \(error.localizedDescription)")
                    return
                }
                
                self.dismiss(animated: true)
            }
        }
    }

}

extension SetProfileController {
    
    func setup() {
        plusPhotoButton.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendProfileImage), for: .touchUpInside)
    }
    
    func style() {
        view.backgroundColor = .white
        plusPhotoButton.setImage(UIImage(named: "plus_photo"), for: .normal)
        plusPhotoButton.tintColor = .lightGray
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        
        sendButton.setTitle("送出", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 5
        sendButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        sendButton.backgroundColor = .systemBrown
    }
    
    func layout() {
        view.addSubview(plusPhotoButton)
        view.addSubview(sendButton)
        plusPhotoButton.center(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)

        sendButton.setDimensions(height: 36, width: 80)
        sendButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 80)
        sendButton.centerX(inView: view)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SetProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
