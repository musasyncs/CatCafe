//
//  PostCameraController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/20.
//

import UIKit
import AVFoundation

class PostCameraController: UIViewController {
    
    private var session: AVCaptureSession?
    private let output = AVCapturePhotoOutput()
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: - View
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage.asset(.right_arrow)?
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    lazy var capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage.asset(.capture_photo)?
                .resize(to: CGSize(width: 96, height: 96))?
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
    }

    private func setupCaptureButton() {
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(bottom: view.bottomAnchor, paddingBottom: 24)
        capturePhotoButton.setDimensions(height: 96, width: 96)
        capturePhotoButton.centerX(inView: view)
        
        view.addSubview(dismissButton)
        dismissButton.anchor(
            top: view.topAnchor,
            right: view.rightAnchor,
            paddingTop: 24,
            paddingRight: 12
        )
        dismissButton.setDimensions(height: 50, width: 50)
    }
    
    // MARK: - Helper
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCaptureSession()
                }
                return
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCaptureSession()
        @unknown default:
            break
        }
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        // 1. Setup inputs
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return}
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input:", err)
        }
        
        // 2. Setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // 3. Setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        self.session = captureSession
        
        // setup button
        setupCaptureButton()
    }
        
    // MARK: - Action
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleCapturePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
    }
    
}

// MARK: - AVCapturePhotoCaptureDelegate
extension PostCameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let imageData = photo.fileDataRepresentation()
        let previewImage = UIImage(data: imageData!)
        session?.stopRunning()
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        view.addSubview(containerView)
        containerView.fillSuperView()        
    }
    
}
