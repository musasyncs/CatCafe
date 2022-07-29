//
//  RegistrationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import AVFoundation

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class RegistrationController: BaseAuthController {
    
    weak var delegate: AuthenticationDelegate?
    private var viewModel = RegistrationViewModel()

    // MARK: - View
    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            emailContainerView, passwordContainerView,
            fullnameContainerView, usernameContainerView, signUpButton
        ]
    )
    private let emailTextField = RegTextField(placeholder: "Email")
    private let passwordTextField = RegTextField(placeholder: "Password")
    private let fullnameTextField = RegTextField(placeholder: "Full name")
    private let usernameTextField = RegTextField(placeholder: "User name")
    
    lazy var emailContainerView = RegInputContainerView(
        imageName: "mail",
        textField: emailTextField
    )
    lazy var passwordContainerView = RegInputContainerView(
        imageName: "lock",
        textField: passwordTextField
    )
    lazy var fullnameContainerView = RegInputContainerView(
        imageName: "user",
        textField: fullnameTextField
    )
    lazy var usernameContainerView = RegInputContainerView(
        imageName: "user",
        textField: usernameTextField
    )
    
    private let signUpButton = UIButton(type: .system)
    private lazy var alreadyHaveAccountButton = UIButton(type: .system)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSignUpButton()
        setupStackView()
        setupTextFields()
        setupAlreadyHaveAccountButton()
        
        updateForm()        
    }
    
    override func buildPlayer() -> AVPlayer? {
        guard let filePath = Bundle.main.path(forResource: "reg_bg_video", ofType: "mp4") else { return nil }
        let url = URL(fileURLWithPath: filePath)
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.isMuted = true
        return player
    }
    
    // MARK: - Action
    // swiftlint:disable all
    @objc func handleSignUp() {
        guard let email = emailTextField.text else {
            AlertHelper.showMessage(title: "Validate Failed", message: "欄位不可留白", buttonTitle: "OK", over: self)
            return
        }
        guard let password = passwordTextField.text else {
            AlertHelper.showMessage(title: "Validate Failed", message: "欄位不可留白", buttonTitle: "OK", over: self)
            return
        }
        guard let fullname = fullnameTextField.text else {
            AlertHelper.showMessage(title: "Validate Failed", message: "欄位不可留白", buttonTitle: "OK", over: self)
            return
        }
        guard let username = usernameTextField.text?.lowercased() else {
            AlertHelper.showMessage(title: "Validate Failed", message: "欄位不可留白", buttonTitle: "OK", over: self)
            return
        }
            
        showHud()
        AuthService.shared.registerUser(
            withEmail: email,
            password: password
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let authUser):
                self.dismissHud()
                
                self.showHud()
                UserService.shared.createUserProfile(
                    uid: authUser.uid,
                    email: email,
                    username: username,
                    fullname: fullname,
                    profileImageUrlString: "",
                    bioText: "",
                    blockedUsers: []
                ) { [weak self] error in
                    guard let self = self else { return }
                    
                    if error != nil {
                        self.dismissHud()
                        self.showFailure(text: "無法建立使用者")
                        return
                    }
                    
                    LocalStorage.shared.saveUid(authUser.uid)
                    LocalStorage.shared.hasLogedIn = true

                    self.delegate?.authenticationDidComplete()
                }
            case .failure:
                self.dismissHud()
                self.showFailure(text: "Failed to create auth user")
            }
        }
    }
    // swiftlint:enable all
    
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
    
}

extension RegistrationController {

    private func setupSignUpButton() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        signUpButton.setTitle("註冊", for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 5
        signUpButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        signUpButton.backgroundColor = .ccPrimary
        signUpButton.setHeight(36)
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.anchor(left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingLeft: 48, paddingRight: 48)
        stackView.centerY(inView: view)
    }
    
    private func setupTextFields() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.textContentType = .oneTimeCode
        emailTextField.keyboardType = .asciiCapable
        
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.textContentType = .oneTimeCode
        passwordTextField.keyboardType = .asciiCapable
        passwordTextField.isSecureTextEntry = true
        
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.textContentType = .oneTimeCode
        usernameTextField.keyboardType = .asciiCapable
        
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.textContentType = .oneTimeCode
        fullnameTextField.keyboardType = .asciiCapable
    }
 
    private func setupAlreadyHaveAccountButton() {
        alreadyHaveAccountButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        alreadyHaveAccountButton.attributedTitle1(firstPart: "已經註冊了? ", secondPart: "立即登入")
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: logoImageView.topAnchor, paddingBottom: 28)
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
