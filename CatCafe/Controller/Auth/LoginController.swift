//
//  LoginController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import AVFoundation
import Combine
import WebKit

class LoginController: UIViewController {
    
    weak var delegate: AuthenticationDelegate?
    private var viewModel = LoginViewModel()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let notificationCenter = NotificationCenter.default
    private var appEventSubscribers = [AnyCancellable]()
    
    // MARK: - View
    private lazy var darkView = UIView()
    private lazy var logoTextImageView = UIImageView()
    private lazy var subtitleLabel = makeLabel(
        withTitle: "雙北貓咪咖啡廳聚會＆社群",
        font: .monospacedSystemFont(ofSize: 16, weight: .medium),
        textColor: .ccGreyVariant
    )
    private lazy var emailTextField = RegTextField(placeholder: "Email")
    private lazy var passwordTextField = RegTextField(placeholder: "Password")
    private lazy var emailContainerView = InputContainerView(
        imageName: ImageAsset.mail.rawValue,
        textField: emailTextField
    )
    private lazy var passwordContainerView = InputContainerView(
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
    
    private lazy var logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    private lazy var privacyButton = UIButton(type: .system)
    private lazy var eulaButton = UIButton(type: .system)
    private lazy var notMemberButton = UIButton(type: .system)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupDarkView()
        setupNavBar()
        setupLogoText()
        setupSubtitleLabel()
        setupSignInButton()
        setupSignInWithAppleButton()
        setupStackView()
        setupTextFields()
        
        setupLogo()
        setupPrivacyButton()
        setupEulaButton()
        setupNotMemberButton()
        
        updateForm()
        
        setupNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeAppEvents()
        setupPlayerIfNeeded()
        restartVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        removeAppEventsSubscribers()
        removePlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Action
    @objc func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showMessage(withTitle: "Validate Failed", message: "欄位不可留白")
            return
        }
        
        show()
        AuthService.shared.loginUser(withEmail: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.dismiss()
                
                // Save uid; hasLogedIn = true
                LocalStorage.shared.saveUid(user.uid)
                LocalStorage.shared.hasLogedIn = true
                
                self.delegate?.authenticationDidComplete()
            case .failure:
                self.dismiss()
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
        let controller = WebView()
        controller.url = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        present(controller, animated: true)
    }
    
    @objc func openPrivacyWebView() {
        let controller = WebView()
        controller.url = "https://www.privacypolicies.com/live/8a57272b-85c4-4dc1-bf1e-f0953951def3"
        present(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        updateForm()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let distance = CGFloat(50)
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

extension LoginController {
    
    private func setupDarkView() {
        darkView.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(darkView)
        darkView.fillSuperView()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    private func setupLogoText() {
        logoTextImageView.image = UIImage.asset(.logo_text)?.withTintColor(.white)
        logoTextImageView.contentMode = .scaleAspectFit
        view.addSubview(logoTextImageView)
        logoTextImageView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 64, paddingLeft: 104, paddingRight: 104,
            height: 84
        )
    }
    
    private func setupSubtitleLabel() {
        view.addSubview(subtitleLabel)
        subtitleLabel.anchor(
            top: logoTextImageView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 4, paddingLeft: 101, paddingRight: 101,
            height: 20
        )
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
        stackView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 48, paddingRight: 48
        )
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
    
    private func setupLogo() {
        logoImageView.image = UIImage.asset(.logo)?
            .resize(to: .init(width: 40, height: 40))?
            .withRenderingMode(.alwaysOriginal)
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view)
        logoImageView.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 32
        )
    }
    
    private func setupPrivacyButton() {
        privacyButton.addTarget(self, action: #selector(openPrivacyWebView), for: .touchUpInside)
        privacyButton.attributedTitle2(firstPart: "並確認您已詳閱我們的 ", secondPart: "《隱私權政策》")
        view.addSubview(privacyButton)
        privacyButton.centerX(inView: view)
        privacyButton.anchor(
            bottom: logoImageView.topAnchor,
            paddingBottom: 8
        )
    }
    
    private func setupEulaButton() {
        eulaButton.addTarget(self, action: #selector(openEulaWebView), for: .touchUpInside)
        
        eulaButton.attributedTitle2(firstPart: "繼續使用代表您同意 CatCafe 的 ", secondPart: "《服務條款》")
        view.addSubview(eulaButton)
        eulaButton.centerX(inView: view)
        eulaButton.anchor(
            bottom: privacyButton.topAnchor,
            paddingBottom: 0
        )
    }
            
    private func setupNotMemberButton() {
        notMemberButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        notMemberButton.attributedTitle1(firstPart: "尚未成為會員？ ", secondPart: "立即註冊")
        view.addSubview(notMemberButton)
        notMemberButton.centerX(inView: view)
        notMemberButton.anchor(
            bottom: eulaButton.topAnchor,
            paddingBottom: 36
        )
    }
        
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
        show()
        AuthService.shared.authorizationController(
            controller: controller,
            didCompleteWithAuthorization: authorization
        ) { authDataResult in
            
            guard let authDataResult = authDataResult else {
                self.dismiss()
                self.showFailure(text: "失敗")
                return
            }
            self.dismiss() // 登入成功
            
            // 拿 currentUid, userEmail, Apple givenName
            let currentUid = authDataResult.user.uid
            let userEmail = authDataResult.user.email
            var userName: String?
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                userName = appleIDCredential.fullName?.givenName
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            let dispatchQueue = DispatchQueue.global(qos: .background)
            
            UserService.shared.checkIfUserExistOnFirebase(uid: currentUid) { result in
                switch result {
                case .success(let isExist):
                    // 已註冊過
                    if isExist {
                        self.show()
                        
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
                            ) { error in
                                if error != nil {
                                    self.dismiss()
                                    self.showFailure(text: "失敗")
                                    return
                                }
                                LocalStorage.shared.saveUid(currentUid)
                                LocalStorage.shared.hasLogedIn = true
                                semaphore.signal()
                            }
                            semaphore.wait()
                            
                            DispatchQueue.main.async {
                                self.dismiss()
                                self.delegate?.authenticationDidComplete()
                            }
                            
                        }
                    } else {
                        // 尚未註冊
                        self.show()
                        
                        dispatchQueue.async {
                            UserService.shared.createUserProfile(
                                uid: currentUid,
                                email: userEmail ?? "",
                                username: userName ?? "User Name",
                                fullname: userName ?? "Full Name",
                                profileImageUrlString: "",
                                bioText: "",
                                blockedUsers: []
                            ) { error in
                                if error != nil {
                                    self.dismiss()
                                    self.showFailure(text: "失敗")
                                    return
                                }
                                LocalStorage.shared.saveUid(currentUid)
                                LocalStorage.shared.hasLogedIn = true
                                semaphore.signal()
                            }
                            semaphore.wait()
                            
                            DispatchQueue.main.async {
                                self.dismiss()
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

// MARK: - Player
// swiftlint:disable all
extension LoginController {
    
    private func buildPlayer() -> AVPlayer? {
        guard let filePath = Bundle.main.path(forResource: "login_bg_video", ofType: "mp4") else { return nil }
        let url = URL(fileURLWithPath: filePath)
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.isMuted = true
        return player
    }
    
    private func buildPlayerLayer() -> AVPlayerLayer? {
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    private func playVideo() {
        player?.play()
    }
    
    private func restartVideo() {
        player?.seek(to: .zero)
        playVideo()
    }
    
    private func pauseVideo() {
        player?.pause()
    }
    
    private func setupPlayerIfNeeded() {
        player = buildPlayer()
        playerLayer = buildPlayerLayer()
        
        if let layer = self.playerLayer,
            view.layer.sublayers?.contains(layer) == false {
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    
    private func removePlayer() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    private func observeAppEvents() {
        
        notificationCenter.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { [weak self] _ in
            self?.restartVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self] _ in
            self?.pauseVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
            self?.playVideo()
        }.store(in: &appEventSubscribers)
    }
    
    private func removeAppEventsSubscribers() {
        appEventSubscribers.forEach { subscriber in
            subscriber.cancel()
        }
    }
}
// swiftlint:enable all
