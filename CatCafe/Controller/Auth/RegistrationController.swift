//
//  RegistrationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class RegistrationController: UIViewController {
    
    weak var delegate: AuthenticationDelegate?
    
    private var viewModel = RegistrationViewModel()
    private var profileImage: UIImage?

    private let plusPhotoButton = UIButton(type: .system)
    private lazy var stackView = UIStackView(
        arrangedSubviews: [emailTextField, passwordTextField, fullnameTextField, usernameTextField, signUpButton]
    )
    private let emailTextField = CustomTextField(placeholder: "Email")
    private let passwordTextField = CustomTextField(placeholder: "Password")
    private let fullnameTextField = CustomTextField(placeholder: "Fullname")
    private let usernameTextField = CustomTextField(placeholder: "Username")
    private let signUpButton = UIButton(type: .system)
    private lazy var alreadyHaveAccountButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
        configureNotificationObservers()
        
        updateForm()
    }
    
    // MARK: - Action
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let profileImage = profileImage else { return }
        
        let credentials = AuthCredentials(
            email: email,
            password: password,
            fullname: fullname,
            username: username,
            profileImage: profileImage
        )
        
        AuthService.registerUser(withCredial: credentials) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let authUser):
                ImageUplader.uploadProfileImage(image: credentials.profileImage) { imageUrlString in
                    UserService.createUserProfile(
                        userId: authUser.uid,
                        profileImageUrlString: imageUrlString,
                        credentials: credentials
                    ) { error in
                        if let error = error {
                            print("DEBUG: Failed to create user profile with error: \(error.localizedDescription)")
                            return
                        }
                        
                        // Save uid; hasLogedIn = true
                        LocalStorage.shared.saveUid(authUser.uid)
                        LocalStorage.shared.hasLogedIn = true
                        
                        self.delegate?.authenticationDidComplete()
                    }
                }
            case .failure(let error):
                print("DEBUG: Failed to create authUser with error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == fullnameTextField {
            viewModel.fullname = sender.text
        } else {
            viewModel.username = sender.text
        }
        updateForm()
    }
    
    @objc func handleProfilePhotoSelect() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
}

extension RegistrationController {
    
    func setup() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        plusPhotoButton.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        alreadyHaveAccountButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
    }
    
    func style() {
        plusPhotoButton.setImage(UIImage(named: "plus_photo"), for: .normal)
        plusPhotoButton.tintColor = .lightGray
        stackView.axis = .vertical
        stackView.spacing = 20
        emailTextField.keyboardType = .emailAddress
        passwordTextField.isSecureTextEntry = true
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.layer.cornerRadius = 5
        signUpButton.titleLabel?.font = .notoMedium(size: 15)
        signUpButton.backgroundColor = .systemPurple.withAlphaComponent(0.5)
        alreadyHaveAccountButton.attributedTitle(firstPart: "Already have an account?  ", secondPart: "Log In")
    }
    
    func layout() {
        view.addSubview(plusPhotoButton)
        view.addSubview(stackView)
        view.addSubview(alreadyHaveAccountButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        stackView.anchor(
            top: plusPhotoButton.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 48, paddingLeft: 48, paddingRight: 48
        )
        emailTextField.setHeight(36)
        passwordTextField.setHeight(36)
        fullnameTextField.setHeight(36)
        usernameTextField.setHeight(36)
        signUpButton.setHeight(36)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

// MARK: - FormViewModel

extension RegistrationController: FormViewModel {
    func updateForm() {
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        profileImage = selectedImage
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        self.dismiss(animated: true)
    }
}
