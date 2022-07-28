//
//  LoginController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import WebKit
import AVFoundation

class LoginController: BaseAuthController {
    
    weak var delegate: AuthenticationDelegate?
    private var viewModel = LoginViewModel()
    
    // MARK: - View
    private lazy var emailTextField = RegTextField(placeholder: "Email")
    private lazy var passwordTextField = RegTextField(placeholder: "Password")
    private lazy var emailContainerView = RegInputContainerView(
        imageName: ImageAsset.mail.rawValue,
        textField: emailTextField
    )
    private lazy var passwordContainerView = RegInputContainerView(
        imageName: ImageAsset.lock.rawValue,
        textField: passwordTextField
    )
    private lazy var loginButton = UIButton(type: .system)
    private lazy var signInWithAppleButton = ASAuthorizationAppleIDButton(
        authorizationButtonType: .signIn,
        authorizationButtonStyle: .white
    )
    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            emailContainerView,
            passwordContainerView,
            loginButton,
            signInWithAppleButton
        ]
    )

    private lazy var privacyButton = UIButton(type: .system)
    private lazy var eulaButton = UIButton(type: .system)
    private lazy var notMemberButton = UIButton(type: .system)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavBar()
        setupSignInButton()
        setupSignInWithAppleButton()
        setupStackView()
        setupTextFields()
        
        setupPrivacyButton()
        setupEulaButton()
        setupNotMemberButton()
        
        updateForm()        
    }
    
    override func buildPlayer() -> AVPlayer? {
        guard let filePath = Bundle.main.path(forResource: "login_bg_video", ofType: "mp4") else { return nil }
        let url = URL(fileURLWithPath: filePath)
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.isMuted = true
        return player
    }
        
    // MARK: - Action
    @objc func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            AlertHelper.showMessage(title: "Validate Failed", message: "欄位不可留白", buttonTitle: "OK", over: self)
            return
        }
        
        showHud()
        AuthService.shared.loginUser(withEmail: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.dismissHud()
                
                // Save uid; hasLogedIn = true
                LocalStorage.shared.saveUid(user.uid)
                LocalStorage.shared.hasLogedIn = true
                
                self.delegate?.authenticationDidComplete()
            case .failure:
                self.dismissHud()
                self.showFailure(text: "失敗")
            }
        }
    }
    
    @objc func handleSignInWithAppleTapped() {
        let request = AuthService.shared.createAppleIDRequest()
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @objc func handleShowSignUp() {
        let regController = RegistrationController()
        regController.delegate = self.delegate
        navigationController?.pushViewController(regController, animated: true)
    }
    
    @objc func openEulaWebView() {
        presentWebVC(with: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    }
    
    @objc func openPrivacyWebView() {
        presentWebVC(with: "https://www.privacypolicies.com/live/8a57272b-85c4-4dc1-bf1e-f0953951def3")
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
    
    private func setupNavBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }

    private func setupSignInButton() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.setTitle("登入", for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        loginButton.setHeight(36)
    }
    
    private func setupSignInWithAppleButton() {
        signInWithAppleButton.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
        signInWithAppleButton.setHeight(45)
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
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .asciiCapable
        
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .oneTimeCode
        passwordTextField.keyboardType = .asciiCapable
    }

    private func setupPrivacyButton() {
        privacyButton.addTarget(self, action: #selector(openPrivacyWebView), for: .touchUpInside)
        privacyButton.attributedTitle2(firstPart: "並確認您已詳閱我們的 ", secondPart: "《隱私權政策》")
        view.addSubview(privacyButton)
        privacyButton.centerX(inView: view)
        privacyButton.anchor(bottom: logoImageView.topAnchor, paddingBottom: 8)
    }
    
    private func setupEulaButton() {
        eulaButton.addTarget(self, action: #selector(openEulaWebView), for: .touchUpInside)
        
        eulaButton.attributedTitle2(firstPart: "繼續使用代表您同意 CatCafe 的 ", secondPart: "《服務條款》")
        view.addSubview(eulaButton)
        eulaButton.centerX(inView: view)
        eulaButton.anchor(bottom: privacyButton.topAnchor, paddingBottom: 0)
    }
    
    private func setupNotMemberButton() {
        notMemberButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        notMemberButton.attributedTitle1(firstPart: "尚未成為會員？ ", secondPart: "立即註冊")
        view.addSubview(notMemberButton)
        notMemberButton.centerX(inView: view)
        notMemberButton.anchor(bottom: eulaButton.topAnchor, paddingBottom: 36)
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

// MARK: - ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding
extension LoginController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
    
    // swiftlint:disable all
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        showHud()
        AuthService.shared.authorizationController(
            controller: controller,
            didCompleteWithAuthorization: authorization
        ) { [weak self] authDataResult in
            guard let self = self else { return }
            
            guard let authDataResult = authDataResult else {
                self.dismissHud()
                self.showFailure(text: "失敗")
                return
            }
            self.dismissHud() // 登入成功
            
            // 拿 currentUid, userEmail, Apple givenName
            let currentUid = authDataResult.user.uid
            let userEmail = authDataResult.user.email
            var userName: String?
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                userName = appleIDCredential.fullName?.givenName
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            let dispatchQueue = DispatchQueue.global(qos: .background)
            
            UserService.shared.checkIfUserExistOnFirebase(uid: currentUid) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let isExist):
                    // 已註冊過
                    if isExist {
                        self.showHud()
                        
                        dispatchQueue.async {
                            var userEmail: String?
                            var username: String?
                            var fullname: String?
                            var profileImageUrlString: String?
                            var bioText: String?
                            var blockedUsers = [String]()
                            
                            UserService.shared.fetchUserBy(uid: currentUid) { user in
                                userEmail = user.email
                                username = user.username
                                fullname = user.fullname
                                profileImageUrlString = user.profileImageUrlString
                                bioText = user.bioText
                                blockedUsers = user.blockedUsers
                                semaphore.signal()
                            }
                            semaphore.wait()
                            
                            UserService.shared.createUserProfile(
                                uid: currentUid,
                                email: userEmail ?? "",
                                username: username ?? "",
                                fullname: fullname ?? "",
                                profileImageUrlString: profileImageUrlString ?? "",
                                bioText: bioText ?? "",
                                blockedUsers: blockedUsers
                            ) { [weak self] error in
                                guard let self = self else { return }
                                if error != nil {
                                    self.dismissHud()
                                    self.showFailure(text: "失敗")
                                    return
                                }
                                LocalStorage.shared.saveUid(currentUid)
                                LocalStorage.shared.hasLogedIn = true
                                semaphore.signal()
                            }
                            semaphore.wait()
                            
                            DispatchQueue.main.async {
                                self.dismissHud()
                                self.delegate?.authenticationDidComplete()
                            }
                            
                        }
                    } else {
                        // 尚未註冊
                        self.showHud()
                        
                        dispatchQueue.async {
                            UserService.shared.createUserProfile(
                                uid: currentUid,
                                email: userEmail ?? "",
                                username: userName ?? "User Name",
                                fullname: userName ?? "Full Name",
                                profileImageUrlString: "",
                                bioText: "",
                                blockedUsers: []
                            ) { [weak self] error in
                                guard let self = self else { return }
                                if error != nil {
                                    self.dismissHud()
                                    self.showFailure(text: "失敗")
                                    return
                                }
                                LocalStorage.shared.saveUid(currentUid)
                                LocalStorage.shared.hasLogedIn = true
                                semaphore.signal()
                            }
                            semaphore.wait()
                            
                            DispatchQueue.main.async {
                                self.dismissHud()
                                self.delegate?.authenticationDidComplete()
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        }
    }
    // swiftlint:enable all
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
