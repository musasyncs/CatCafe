//
//  AttendMeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit

class AttendMeetController: UIViewController {
    
    let meet: Meet
    
    let bottomView = UIView()
    let titleLabel = UILabel()
    let topDivider = UIView()
    
    let contactLabel = UILabel()
    
    override var inputAccessoryView: UIView? { return nil }
    override var canBecomeFirstResponder: Bool { return true }

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
    
    let contactCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.text = "0/100"
        label.textAlignment = .center
        return label
    }()
    
    let remarkLabel = UILabel()

    lazy var remarkTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderText = "輸入想對聚會主說的話"
        textView.font = .systemFont(ofSize: 13, weight: .regular)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.placeholderShouldCenter = false
        return textView
    }()
    
    let remarkCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.text = "0/150"
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel = UILabel()
    let bottomDivider = UIView()
    let centerDivider = UIView()
    let cancelButton = makeTitleButton(withText: "取消", font: .notoRegular(size: 12), foregroundColor: .systemRed)
    let sendButton = makeTitleButton(withText: "送出", font: .notoRegular(size: 12))
    
    var bottomConstraint: NSLayoutConstraint?
    var popupOffset: CGFloat = UIScreen.height *  0.7

    // MARK: - Life Cycle
    
    init(meet: Meet) {
        self.meet = meet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomConstraint?.constant = popupOffset
        view.backgroundColor = .black.withAlphaComponent(0)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomConstraint?.constant = 0
            self.view.backgroundColor = .black.withAlphaComponent(0.4)
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Action
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func sendTapped() {
        guard let contact = contactTextView.text, contact.isEmpty == false,
              let remarks = remarkTextView.text, remarks.isEmpty == false
        else {
            showMessage(withTitle: "Validate Failed", message: "欄位不可留白")
            return
        }
        
        showLoader(true)
        MeetService.attendMeet(meet: meet,
                               contact: contact,
                               remarks: remarks) { error in
            self.showLoader(false)

            if let error = error {
                print("DEBUG: Failed to attend meet with error \(error.localizedDescription)")
                return
            }

            // dismiss
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

            // update meet feed
            NotificationCenter.default.post(name: CCConstant.NotificationName.updateMeetFeed, object: nil)
        }
    }
    
}

extension AttendMeetController {
    
    fileprivate func setup() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
    
    fileprivate func style() {
        bottomView.backgroundColor = .white
        bottomView.layer.cornerRadius = 12
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 0, height: 5)
        bottomView.layer.shadowOpacity = 0.7
        bottomView.layer.shadowRadius = 10

        titleLabel.text = "報名聚會"
        titleLabel.textColor = UIColor.rgb(red: 63, green: 58, blue: 58)
        titleLabel.font = .notoMedium(size: 15)
        
        contactLabel.text = "聯絡方式"
        contactLabel.textColor = .systemRed
        contactLabel.font = .notoRegular(size: 15)
        contactTextView.backgroundColor = .systemGray6
        
        remarkLabel.text = "想對聚會主說的話"
        remarkLabel.textColor = .black
        remarkLabel.font = .notoRegular(size: 15)
        remarkTextView.backgroundColor = .systemGray6
        
        descriptionLabel.text = "收到您的報名資訊，聚會主會決定是否透過上述資訊聯絡您。"
        descriptionLabel.textColor = .lightGray
        descriptionLabel.font = .notoRegular(size: 11)
        topDivider.backgroundColor = .lightGray
        bottomDivider.backgroundColor = .lightGray
        centerDivider.backgroundColor = .lightGray
    }
    
    fileprivate func layout() {
        [bottomView, titleLabel, topDivider,
         contactLabel, contactTextView, contactCountLabel,
         remarkLabel, remarkTextView, remarkCountLabel,
         descriptionLabel,
         bottomDivider,
         cancelButton, centerDivider, sendButton].forEach {
            view.addSubview($0)
        }
        
        bottomView.anchor(left: view.leftAnchor,
                          right: view.rightAnchor,
                          height: popupOffset)
        bottomConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint?.isActive = true

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
        contactCountLabel.anchor(bottom: contactTextView.topAnchor, right: contactTextView.rightAnchor)
        
        remarkLabel.anchor(top: contactTextView.bottomAnchor,
                            left: bottomView.leftAnchor,
                            paddingTop: 16,
                            paddingLeft: 16)
        remarkTextView.anchor(top: remarkLabel.bottomAnchor,
                               left: bottomView.leftAnchor,
                               right: bottomView.rightAnchor,
                               paddingTop: 8,
                               paddingLeft: 16,
                               paddingRight: 16)
        remarkTextView.setHeight(50)
        remarkCountLabel.anchor(bottom: remarkTextView.topAnchor, right: contactTextView.rightAnchor)
        
        descriptionLabel.anchor(top: remarkTextView.bottomAnchor,
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
                            paddingLeft: UIScreen.width / 5)
        cancelButton.setHeight(48)
        sendButton.anchor(top: bottomDivider.bottomAnchor,
                          bottom: bottomView.bottomAnchor,
                          right: bottomView.rightAnchor,
                          paddingRight: UIScreen.width / 5)
        sendButton.setHeight(48)
        centerDivider.setDimensions(height: 20, width: 1)
        centerDivider.centerX(inView: view)
        centerDivider.centerY(inView: cancelButton)
    }
}

// MARK: - UITextViewDelegate

extension AttendMeetController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == contactTextView {
            if textView.text.count > 100 {
                textView.deleteBackward()
            }
            contactCountLabel.text  = "\(textView.text.count)/100"
        } else {
            if textView.text.count > 150 {
                textView.deleteBackward()
            }
            remarkCountLabel.text  = "\(textView.text.count)/150"
        }
            
        let size = CGSize(width: bottomView.frame.width - 32, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
