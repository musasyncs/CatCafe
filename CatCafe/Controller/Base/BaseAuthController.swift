//
//  BaseAuthController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/28.
//

import UIKit
import AVFoundation
import Combine

class BaseAuthController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let notificationCenter = NotificationCenter.default
    private var appEventSubscribers = [AnyCancellable]()
    
    let darkView = UIView()
    let logoTextImageView = UIImageView()
    let subtitleLabel = makeLabel(withTitle: "雙北貓咪咖啡廳聚會＆社群",
                                  font: .monospacedSystemFont(ofSize: 16, weight: .medium),
                                  textColor: .ccGreyVariant)
    lazy var logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDarkView()
        setupLogoText()
        setupSubtitleLabel()
        
        setupLogoImageView()
        
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
    
    // MARK: - Function
    func setupDarkView() {
        darkView.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(darkView)
        darkView.fillSuperView()
    }
    
    func setupLogoText() {
        logoTextImageView.image = UIImage.asset(.logo_text)?.withTintColor(.white)
        logoTextImageView.contentMode = .scaleAspectFit
        view.addSubview(logoTextImageView)
        logoTextImageView.anchor(top: view.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 paddingTop: 64, paddingLeft: 104, paddingRight: 104,
                                 height: 84)
    }
    
    func setupSubtitleLabel() {
        view.addSubview(subtitleLabel)
        subtitleLabel.anchor(top: logoTextImageView.bottomAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 4, paddingLeft: 101, paddingRight: 101,
                             height: 20)
    }
    
    func setupLogoImageView() {
        logoImageView.image = UIImage.asset(.logo)?
            .resize(to: .init(width: 40, height: 40))?
            .withRenderingMode(.alwaysOriginal)
        logoImageView.alpha = 0.3
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view)
        logoImageView.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 32)
    }
    
    // MARK: - Keyboard show or hide
    func setupNotificationObservers() {
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
    
    // MARK: - Player
    func buildPlayer() -> AVPlayer? {
        return nil
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
    
    // MARK: - Action
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
