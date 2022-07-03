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

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            emailContainerView, passwordContainerView,
            fullnameContainerView, usernameContainerView, signUpButton
        ]
    )
    let emailTextField = RegTextField(placeholder: "Email")
    let passwordTextField = RegTextField(placeholder: "Password")
    let fullnameTextField = RegTextField(placeholder: "Full name")
    let usernameTextField = RegTextField(placeholder: "User name")
    
    lazy var emailContainerView = InputContainerView(imageName: "mail",
                                                     textField: emailTextField)
    lazy var passwordContainerView = InputContainerView(imageName: "lock",
                                                        textField: passwordTextField)
    lazy var fullnameContainerView = InputContainerView(imageName: "user",
                                                        textField: fullnameTextField)
    lazy var usernameContainerView = InputContainerView(imageName: "user",
                                                        textField: usernameTextField)

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
        guard let email = emailTextField.text else {
            showMessage(withTitle: "Validate Failed", message: "欄位不可留白")
            return
        }
        guard let password = passwordTextField.text else {
            showMessage(withTitle: "Validate Failed", message: "欄位不可留白")
            return
        }
        guard let fullname = fullnameTextField.text else {
            showMessage(withTitle: "Validate Failed", message: "欄位不可留白")
            return
        }
        guard let username = usernameTextField.text?.lowercased() else {
            showMessage(withTitle: "Validate Failed", message: "欄位不可留白")
            return
        }
        
        let credentials = AuthCredentials(email: email,
                                          password: password,
                                          fullname: fullname,
                                          username: username)
        CCProgressHUD.show()
        AuthService.shared.registerUser(withCredial: credentials) { [weak self] result in
            CCProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let authUser):
                
                UserService.shared.createUserProfile(
                    userId: authUser.uid,
                    profileImageUrlString: "",
                    credentials: credentials
                ) { error in
                    
                    if let error = error {
                        CCProgressHUD.showFailure()
                        print("DEBUG: Failed to create user profile with error: \(error.localizedDescription)")
                        return
                    }
                    
                    // Save uid; hasLogedIn = true; save user
                    LocalStorage.shared.saveUid(authUser.uid)
                    LocalStorage.shared.hasLogedIn = true

                    self.delegate?.authenticationDidComplete()
                }
            case .failure(let error):
                CCProgressHUD.showFailure()
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

extension RegistrationController {
    
    func setup() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        alreadyHaveAccountButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
    }
    
    func style() {
        view.backgroundColor = .white
        stackView.axis = .vertical
        stackView.spacing = 20
        passwordTextField.isSecureTextEntry = true
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 5
        signUpButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        signUpButton.backgroundColor = .systemBrown
        alreadyHaveAccountButton.attributedTitle(firstPart: "Already have an account?  ", secondPart: "Log In")
        
        // 防止 Strong password overlay 和 Emoji 輸入
        emailTextField.textContentType = .oneTimeCode
        passwordTextField.textContentType = .oneTimeCode
        usernameTextField.textContentType = .oneTimeCode
        fullnameTextField.textContentType = .oneTimeCode
        emailTextField.keyboardType = .asciiCapable
        passwordTextField.keyboardType = .asciiCapable
        usernameTextField.keyboardType = .asciiCapable
        fullnameTextField.keyboardType = .asciiCapable
    }
    
    func layout() {
        view.addSubview(stackView)
        view.addSubview(alreadyHaveAccountButton)
        stackView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 48, paddingRight: 48
        )
        stackView.center(inView: view)
        signUpButton.setHeight(36)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
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
