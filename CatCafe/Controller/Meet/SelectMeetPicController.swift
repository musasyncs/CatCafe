//
//  UploadMeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit
import Photos

class SelectMeetPicController: UIViewController {
        
    var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            meetPicView.placedImageView.image = selectedImage
        }
    }

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    private lazy var meetPicView: MeetPicView = {
        let view = MeetPicView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(selectMeetImage))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(recognizer)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style
        view.backgroundColor = .white
        titleLabel.text = "設定封面"
        titleLabel.font = .notoMedium(size: 15)
        subtitleLabel.text = "請上傳一張照片作為封面"
        subtitleLabel.font = .notoRegular(size: 13)
        setupNavigationButtons()
        
        // layout
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(meetPicView)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 16)
        titleLabel.centerX(inView: view)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, paddingTop: 8)
        subtitleLabel.centerX(inView: view)
        meetPicView.anchor(top: subtitleLabel.bottomAnchor, paddingTop: 16)
        meetPicView.centerX(inView: view)
        meetPicView.setDimensions(height: 180, width: 180)
    }
    
    // MARK: - Helpers
    
    func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Icons_24px_Close")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.right")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleNext)
        )
    }
    
    func showImagePicker(mode: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = mode
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Action
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func handleNext() {
        guard let selectedImage = selectedImage else {
            showMessage(withTitle: "", message: "請上傳聚會封面")
            return
        }
        let controller = ArrangeMeetController()
        controller.selectedImage = selectedImage
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func selectMeetImage() {
        let actionSheet = UIAlertController(title: "Add a Photo",
                                            message: "Select a source:",
                                            preferredStyle: .actionSheet)
        
        // Only add the camera button if it's available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                self.showImagePicker(mode: .camera)
            }
            cameraAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
            actionSheet.addAction(cameraAction)
        }
        
        // Only add the library button if it's available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.showImagePicker(mode: .photoLibrary)
            }
            libraryAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
            actionSheet.addAction(libraryAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SelectMeetPicController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.selectedImage = selectedImage
        picker.dismiss(animated: true, completion: nil)
    }
    
}

final class MeetPicView: UIView {
    
    lazy var placedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image  = UIImage(named: "meet-camera")?
            .withRenderingMode(.alwaysOriginal)
            .resize(to: .init(width: 60, height: 60))
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cameraImageView)
        cameraImageView.centerX(inView: self)
        cameraImageView.centerY(inView: self)
        
        addSubview(placedImageView)
        placedImageView.fillSuperView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
