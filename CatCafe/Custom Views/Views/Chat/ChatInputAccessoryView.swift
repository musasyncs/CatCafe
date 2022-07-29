//
//  ChatInputAccessoryView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/6.
//

import UIKit

protocol ChatInputAccessoryViewDelegate: AnyObject {
    func chatInputView(_ inputView: ChatInputAccessoryView, textDidChangeTo text: String)
    func chatInputView(_ inputView: ChatInputAccessoryView, wantsToUploadText text: String)
    func openCamera(_ inputView: ChatInputAccessoryView)
    func openGallery(_ inputView: ChatInputAccessoryView)
}

class ChatInputAccessoryView: UIView {
    
    override var intrinsicContentSize: CGSize { return .zero }
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    private let cameraButton = makeIconButton(
        imagename: ImageAsset.camera_icon.rawValue,
        imageColor: UIColor.ccGrey,
        imageWidth: 22, imageHeight: 22
    )
    private let pictureButton = makeIconButton(
        imagename: ImageAsset.picture_icon.rawValue,
        imageColor: UIColor.ccGrey,
        imageWidth: 20, imageHeight: 20
    )
    private let sendButton = makeIconButton(
        imagename: ImageAsset.send_icon.rawValue,
        imageColor: UIColor.ccGrey,
        imageWidth: 22, imageHeight: 22
    )
    
    static private func makeInputButton(imageName: String, selectedImageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName)?.resize(to: CGSize(width: 22, height: 22)), for: .normal)
        button.setImage(UIImage(named: selectedImageName)?.resize(to: CGSize(width: 22, height: 22)), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }
        
    lazy var chatTextView: InputTextView = {
        let textView = InputTextView()
        textView.delegate = self
        textView.backgroundColor = .ccGreyVariant.withAlphaComponent(0.1)
        textView.layer.cornerRadius = 15
        textView.placeholderText = "訊息"
        textView.placeholderShouldCenter = true
        return textView
    }()
    
    lazy var stackView = UIStackView(
        arrangedSubviews: [cameraButton, pictureButton, chatTextView, sendButton]
    )
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .white.withAlphaComponent(0.7)
        autoresizingMask = .flexibleHeight
        
        cameraButton.addTarget(self, action: #selector(tappedCameraButton), for: .touchUpInside)
        pictureButton.addTarget(self, action: #selector(tappedPictureButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(tappedSendButton), for: .touchUpInside)
        sendButton.isEnabled = false
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.backgroundColor = .clear
        stackView.anchor(top: topAnchor,
                         left: leftAnchor,
                         bottom: safeAreaLayoutGuide.bottomAnchor,
                         right: rightAnchor,
                         paddingTop: 8,
                         paddingLeft: 16,
                         paddingBottom: 8,
                         paddingRight: 16)
        
        chatTextView.anchor(width: 220)
        chatTextView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let divider = UIView()
        divider.backgroundColor = .gray5
        addSubview(divider)
        divider.anchor(top: topAnchor,
                       left: leftAnchor,
                       right: rightAnchor,
                       height: 0.5)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Helper
    func clearChatTextView() {
        chatTextView.text = nil
        chatTextView.placeholderLabel.isHidden = false
    }
    
    // MARK: - Action
    @objc func tappedCameraButton() {
        delegate?.openCamera(self)
    }
    
    @objc func tappedPictureButton() {
        delegate?.openGallery(self)
    }
    
    @objc func tappedSendButton() {
        guard let text = chatTextView.text, text.isEmpty == false else { return }
        delegate?.chatInputView(self, wantsToUploadText: text)
    }
}

extension ChatInputAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
        delegate?.chatInputView(self, textDidChangeTo: textView.text)
    }
    
}
