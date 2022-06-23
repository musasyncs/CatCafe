//
//  AttendMeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit

class AttendMeetController: UIViewController {
    
    let bottomView = UIView()
    let exitButton = UIButton()
    let titleLabel = UILabel()
    let topDivider = UIView()
    let contactLabel = UILabel()

    lazy var contactTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderText = "輸入您最常用的聯絡方式"
        textView.font = .systemFont(ofSize: 13, weight: .regular)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.placeholderShouldCenter = false
        return textView
    }()
    
    let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.text = "0/300"
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel = UILabel()
    let bottomDivider = UIView()
    let cancelButton = makeTitleButton(withText: "取消", font: .notoRegular(size: 12), foregroundColor: .systemRed)
    let sendButton = makeTitleButton(withText: "送出", font: .notoRegular(size: 12))
    
    var bottomConstraint: NSLayoutConstraint?
    var popupOffset: CGFloat = UIScreen.height *  0.5

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.bottomConstraint?.constant = popupOffset
        self.view.backgroundColor = .black.withAlphaComponent(0)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomConstraint?.constant = 0
            self.view.backgroundColor = .black.withAlphaComponent(0.4)
            self.view.layoutIfNeeded()
        })
    }
    
    private func checkMaxlength(_ textView: UITextView) {
        if textView.text.count > 300 {
            textView.deleteBackward()
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func setup() {
        // setup
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
    
    fileprivate func style() {
        // style
        bottomView.backgroundColor = .white
        bottomView.layer.cornerRadius = 12
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 0, height: 5)
        bottomView.layer.shadowOpacity = 0.7
        bottomView.layer.shadowRadius = 10
        
        exitButton.setBackgroundImage(UIImage(named: "Icons_24px_Close"), for: .normal)
        titleLabel.text = "報名聚會"
        titleLabel.textColor = UIColor.rgb(red: 63, green: 58, blue: 58)
        titleLabel.font = .notoMedium(size: 15)
        contactLabel.text = "聯絡方式"
        contactLabel.textColor = .systemRed
        contactLabel.font = .notoRegular(size: 15)
        contactTextView.backgroundColor = .systemGray6
        descriptionLabel.text = "收到您的報名資訊，聚會主會決定是否透過上述資訊聯絡您。"
        descriptionLabel.textColor = .lightGray
        descriptionLabel.font = .notoRegular(size: 11)
        topDivider.backgroundColor = .lightGray
        bottomDivider.backgroundColor = .lightGray
    }
    
    fileprivate func layout() {
        [bottomView, exitButton, titleLabel, topDivider,
         contactLabel, contactTextView, characterCountLabel,
         descriptionLabel,
         bottomDivider,
         cancelButton, sendButton].forEach {
            view.addSubview($0)
        }
        
        bottomView.anchor(left: view.leftAnchor,
                          right: view.rightAnchor,
                          height: popupOffset)
        bottomConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint?.isActive = true
        
        exitButton.anchor(top: bottomView.topAnchor,
                          left: bottomView.leftAnchor,
                          paddingTop: 16, paddingLeft: 16)
        exitButton.setDimensions(height: 24, width: 24)
        
        titleLabel.anchor(top: bottomView.topAnchor, paddingTop: 24)
        titleLabel.centerX(inView: bottomView)
        
        topDivider.anchor(top: titleLabel.bottomAnchor,
                          left: bottomView.leftAnchor,
                          right: bottomView.rightAnchor,
                          paddingTop: 24,
                          paddingLeft: 16,
                          paddingRight: 16)
        topDivider.setHeight(1)
        
        contactLabel.anchor(top: topDivider.bottomAnchor,
                            left: bottomView.leftAnchor,
                            paddingTop: 16,
                            paddingLeft: 16)
        
        contactTextView.anchor(top: contactLabel.bottomAnchor,
                               left: bottomView.leftAnchor,
                               right: bottomView.rightAnchor,
                               paddingTop: 8,
                               paddingLeft: 16,
                               paddingRight: 16)
        contactTextView.setHeight(50)
        
        characterCountLabel.anchor(bottom: contactTextView.topAnchor, right: contactTextView.rightAnchor)
        
        descriptionLabel.anchor(top: contactTextView.bottomAnchor,
                                left: bottomView.leftAnchor,
                                right: bottomView.rightAnchor,
                                paddingTop: 24,
                                paddingLeft: 16,
                                paddingRight: 16)
        
        bottomDivider.anchor(left: bottomView.leftAnchor,
                             right: bottomView.rightAnchor,
                             paddingTop: 24,
                             paddingLeft: 16,
                             paddingRight: 16)
        bottomDivider.setHeight(1)
        
        cancelButton.anchor(top: bottomDivider.bottomAnchor,
                            left: bottomView.leftAnchor,
                            paddingLeft: 64)
        cancelButton.setHeight(48)
        sendButton.anchor(top: bottomDivider.bottomAnchor,
                          bottom: bottomView.bottomAnchor,
                          right: bottomView.rightAnchor,
                          paddingRight: 64)
        sendButton.setHeight(48)
    }
    
    // MARK: - Action
    
    @objc func exitTapped() {
        self.dismiss(animated: false)
    }
    
    @objc func cancelTapped() {
        print("DEBUG: cencel")
    }
    
    @objc func sendTapped() {
        print("DEBUG: send")
    }
    
}

// MARK: - UITextViewDelegate

extension AttendMeetController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxlength(textView)
        let count = textView.text.count
        characterCountLabel.text  = "\(count)/300"
        
        let size = CGSize(width: bottomView.frame.width - 32, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
