//
//  AttendMeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit

class AttendMeetController: UIViewController {
    
    private let meet: Meet
    
    // MARK: - View
    private let popupView = UIView()
    private let titleLabel = UILabel()
    private let topDivider = UIView()
    private let contactLabel = UILabel()
    
    override var inputAccessoryView: UIView? { return nil }
    override var canBecomeFirstResponder: Bool { return true }

    private lazy var contactTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderText = "最常用的聯絡方式"
        textView.backgroundColor = .ccGreyVariant.withAlphaComponent(0.1)
        textView.font = .systemFont(ofSize: 13, weight: .regular)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.placeholderShouldCenter = true
        return textView
    }()
    
    private let contactCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.text = "0/100"
        label.textAlignment = .center
        return label
    }()
    
    private let remarkLabel = UILabel()

    private lazy var remarkTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderText = "想說的話"
        textView.backgroundColor = .ccGreyVariant.withAlphaComponent(0.1)
        textView.font = .systemFont(ofSize: 13, weight: .regular)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.placeholderShouldCenter = true
        return textView
    }()
    
    private let remarkCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.text = "0/150"
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel = UILabel()
    private let bottomDivider = UIView()
    private let centerDivider = UIView()
    private let cancelButton = makeTitleButton(
        withText: "取消",
        font: .systemFont(ofSize: 12, weight: .regular),
        foregroundColor: .systemRed
    )
    private let sendButton = makeTitleButton(
        withText: "送出",
        font: .systemFont(ofSize: 12, weight: .regular)
    )
    
    private var bottomConstraint: NSLayoutConstraint?
    private var popupOffset: CGFloat = UIScreen.height *  0.7

    // MARK: - Initializer
    init(meet: Meet) {
        self.meet = meet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomView()
        setupTitleLabel()
        setupTopDivider()
        setupContactLabel()
        setupContactTextView()
        setupContactCountLabel()
        setupRemarkLabel()
        setupRemarkTextView()
        setupRemarkCountLabel()
        setupDescriptionLabel()
        setupCenterDivider()
        setupCancelButton()
        setupSendButton()
        setupBottomDivider()
        setupObservers()
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
        
        show()
        MeetService.attendMeet(meet: meet,
                               contact: contact,
                               remarks: remarks) { error in
            if error != nil {
                self.dismiss()
                self.showFailure(text: "Failed to attend meet")
                return
            }
            
            self.dismiss()
            
            // dismiss
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

            // update meet feed
            NotificationCenter.default.post(name: CCConstant.NotificationName.updateMeetFeed, object: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let distance = CGFloat(100)
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

extension AttendMeetController {
    
    private func setupBottomView() {
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        popupView.layer.shadowColor = UIColor.ccGrey.cgColor
        popupView.layer.shadowOffset = CGSize(width: 0, height: 5)
        popupView.layer.shadowOpacity = 0.7
        popupView.layer.shadowRadius = 10
        view.addSubview(popupView)
        popupView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: popupOffset
        )
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint?.isActive = true
    }
        
    private func setupTitleLabel() {
        titleLabel.text = "報名聚會"
        titleLabel.textColor = UIColor.rgb(red: 63, green: 58, blue: 58)
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        view.addSubview(titleLabel)
        titleLabel.anchor(top: popupView.topAnchor, paddingTop: 24)
        titleLabel.centerX(inView: popupView)
    }
    
    private func setupTopDivider() {
        topDivider.backgroundColor = .lightGray
        view.addSubview(topDivider)
        topDivider.anchor(
            top: titleLabel.bottomAnchor,
            left: popupView.leftAnchor,
            right: popupView.rightAnchor,
            paddingTop: 24,
            paddingLeft: 16,
            paddingRight: 16
        )
        topDivider.setHeight(1)
    }
    
    private func setupContactLabel() {
        contactLabel.text = "聯絡方式"
        contactLabel.textColor = .systemRed
        contactLabel.font = .systemFont(ofSize: 15, weight: .regular)
        view.addSubview(contactLabel)
        contactLabel.anchor(
            top: topDivider.bottomAnchor,
            left: popupView.leftAnchor,
            paddingTop: 16,
            paddingLeft: 16
        )
    }
    
    private func setupContactTextView() {
        view.addSubview(contactTextView)
        contactTextView.anchor(
            top: contactLabel.bottomAnchor,
            left: popupView.leftAnchor,
            right: popupView.rightAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            paddingRight: 16
        )
    }
    
    private func setupContactCountLabel() {
        view.addSubview(contactCountLabel)
        contactCountLabel.anchor(bottom: contactTextView.topAnchor, right: contactTextView.rightAnchor)
    }
    
    private func setupRemarkLabel() {
        remarkLabel.text = "想對聚會主說的話"
        remarkLabel.textColor = .ccGrey
        remarkLabel.font = .systemFont(ofSize: 15, weight: .regular)
        view.addSubview(remarkLabel)
        remarkLabel.anchor(
            top: contactTextView.bottomAnchor,
            left: popupView.leftAnchor,
            paddingTop: 16,
            paddingLeft: 16
        )
    }
    
    private func setupRemarkTextView() {
        view.addSubview(remarkTextView)
        remarkTextView.anchor(
            top: remarkLabel.bottomAnchor,
            left: popupView.leftAnchor,
            right: popupView.rightAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            paddingRight: 16
        )
    }
    
    private func setupRemarkCountLabel() {
        view.addSubview(remarkCountLabel)
        remarkCountLabel.anchor(bottom: remarkTextView.topAnchor, right: contactTextView.rightAnchor)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.text = "收到您的報名資訊，聚會主會決定是否透過上述資訊聯絡您。"
        descriptionLabel.textColor = .lightGray
        descriptionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(
            top: remarkTextView.bottomAnchor,
            left: popupView.leftAnchor,
            right: popupView.rightAnchor,
            paddingTop: 24,
            paddingLeft: 16,
            paddingRight: 16
        )
    }
    
    private func setupCenterDivider() {
        centerDivider.backgroundColor = .lightGray
        view.addSubview(centerDivider)
        centerDivider.anchor(bottom: popupView.bottomAnchor, paddingBottom: 24)
        centerDivider.setDimensions(height: 20, width: 1)
        centerDivider.centerX(inView: view)
    }
    
    private func setupCancelButton() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.anchor(
            left: popupView.leftAnchor,
            paddingLeft: UIScreen.width / 5
        )
        cancelButton.centerY(inView: centerDivider)
    }
    
    private func setupSendButton() {
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        sendButton.anchor(
            bottom: popupView.bottomAnchor,
            right: popupView.rightAnchor,
            paddingRight: UIScreen.width / 5
        )
        sendButton.centerY(inView: centerDivider)
    }
    
    private func setupBottomDivider() {
        bottomDivider.backgroundColor = .lightGray
        view.addSubview(bottomDivider)
        bottomDivider.anchor(
            left: popupView.leftAnchor,
            bottom: centerDivider.topAnchor,
            right: popupView.rightAnchor,
            paddingLeft: 16,
            paddingBottom: 16,
            paddingRight: 16
        )
        bottomDivider.setHeight(1)
    }

    private func setupObservers() {
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
            
        let size = CGSize(width: popupView.frame.width - 32, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
