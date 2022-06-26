//
//  LoginController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

class LoginController: UIViewController {
    
    weak var delegate: AuthenticationDelegate?
    
    private var viewModel = LoginViewModel()
    
    let emailTextField = RegTextField(placeholder: "Email")
    let passwordTextField = RegTextField(placeholder: "Password")
    lazy var emailContainerView = InputContainerView(imageName: "mail",
                                                     textField: emailTextField)
    lazy var passwordContainerView = InputContainerView(imageName: "lock",
                                                        textField: passwordTextField)
    private lazy var loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            emailContainerView,
            passwordContainerView,
            loginButton,
            forgotPasswordButton
        ]
    )
    
    private lazy var dontHaveAccountButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
        configureNotificationObservers()
    }
        
    // MARK: - Action
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
                  print("DEBUG: email 和 password 不可為空")
                  return
              }
        AuthService.loginUser(withEmail: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let authUser):
                
                // Save uid; hasLogedIn = true
                LocalStorage.shared.saveUid(authUser.uid)
                LocalStorage.shared.hasLogedIn = true
                
                self.delegate?.authenticationDidComplete()
            case .failure(let error):
                print("DEBUG: Failed to log user in \(error.localizedDescription)")
            }
        }
    }
    
    @objc func handleShowSignUp() {
        let regController = RegistrationController()
        regController.delegate = self.delegate
        navigationController?.pushViewController(regController, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        updateForm()
    }
}

extension LoginController {
    
    func setup() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        dontHaveAccountButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        updateForm()
    }
    
    func style() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        stackView.axis = .vertical
        stackView.spacing = 20
        passwordTextField.isSecureTextEntry = true
        loginButton.setTitle("Log In", for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        forgotPasswordButton.attributedTitle(firstPart: "Forgot your password?  ", secondPart: "Get help signing in.")
        dontHaveAccountButton.attributedTitle(firstPart: "Don't have an account?  ", secondPart: "Sign Up")
    }
    
    func layout() {
        view.addSubview(stackView)
        view.addSubview(dontHaveAccountButton)

        stackView.centerY(inView: view)
        stackView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 48, paddingRight: 48
        )
        
        loginButton.setHeight(36)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

// MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}
