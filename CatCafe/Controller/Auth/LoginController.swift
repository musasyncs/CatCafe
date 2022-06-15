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
        
    private let emailTextField = CustomTextField(placeholder: "Email")
    private let passwordTextField = CustomTextField(placeholder: "Password")
    private lazy var loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private lazy var stackView = UIStackView(
        arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton]
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
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to log user in \(error.localizedDescription)")
                return
            }
            self.delegate?.authenticationDidComplete()
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
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        configureGradientLayer()
        stackView.axis = .vertical
        stackView.spacing = 20
        emailTextField.keyboardType = .emailAddress
        passwordTextField.isSecureTextEntry = true
        loginButton.setTitle("Log In", for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        forgotPasswordButton.attributedTitle(firstPart: "Forgot your password?  ", secondPart: "Get help signing in.")
        dontHaveAccountButton.attributedTitle(firstPart: "Don't have an account?  ", secondPart: "Sign Up")
    }
    
    func layout() {
        view.addSubview(stackView)
        view.addSubview(dontHaveAccountButton)

        stackView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 112, paddingLeft: 32, paddingRight: 32
        )
        emailTextField.setHeight(50)
        passwordTextField.setHeight(50)
        loginButton.setHeight(50)
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
