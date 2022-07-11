//
//  RegistrationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import AVFoundation
import Combine

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class RegistrationController: UIViewController {
    
    weak var delegate: AuthenticationDelegate?
    private var viewModel = RegistrationViewModel()
    
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
    
    lazy var emailContainerView = InputContainerView(
        imageName: "mail",
        textField: emailTextField
    )
    lazy var passwordContainerView = InputContainerView(
        imageName: "lock",
        textField: passwordTextField
    )
    lazy var fullnameContainerView = InputContainerView(
        imageName: "user",
        textField: fullnameTextField
    )
    lazy var usernameContainerView = InputContainerView(
        imageName: "user",
        textField: usernameTextField
    )
    
    private let signUpButton = UIButton(type: .system)
    private lazy var alreadyHaveAccountButton = UIButton(type: .system)
    private lazy var logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupDarkView()
        setupLogoText()
        setupSubtitleLabel()
        setupSignUpButton()
        setupStackView()
        setupTextFields()
        setupLogo()
        setupAlreadyHaveAccountButton()
        
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
            
        show()
        AuthService.shared.registerUser(
            withEmail: email,
            password: password
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let authUser):
                self.dismiss()
                
                self.show()
                UserService.shared.createUserProfile(
                    uid: authUser.uid,
                    email: email,
                    username: username,
                    fullname: fullname,
                    profileImageUrlString: "",
                    bioText: "",
                    blockedUsers: []
                ) { error in
                
                    if error != nil {
                        self.dismiss()
                        self.showFailure(text: "無法建立使用者")
                        return
                    }
                    
                    LocalStorage.shared.saveUid(authUser.uid)
                    LocalStorage.shared.hasLogedIn = true

                    self.delegate?.authenticationDidComplete()
                }
            case .failure:
                self.dismiss()
                self.showFailure(text: "Failed to create auth user")
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
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: []
        ) {
            self.view.transform = transform
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: []
        ) {
            self.view.transform = .identity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension RegistrationController {
    
    private func setupDarkView() {
        darkView.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(darkView)
        darkView.fillSuperView()
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
    
    private func setupSignUpButton() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        signUpButton.setTitle("Sign up", for: .normal)
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
        stackView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 48, paddingRight: 48
        )
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
    
    private func setupAlreadyHaveAccountButton() {
        alreadyHaveAccountButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        alreadyHaveAccountButton.attributedTitle(firstPart: "Already have an account?  ", secondPart: "Log In")
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(
            bottom: logoImageView.topAnchor,
            paddingBottom: 28
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
extension RegistrationController: FormViewModel {
    func updateForm() {
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
    }
}

// MARK: - Player
extension RegistrationController {
    
    private func buildPlayer() -> AVPlayer? {
        guard let filePath = Bundle.main.path(forResource: "reg_bg_video", ofType: "mp4") else { return nil }
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
