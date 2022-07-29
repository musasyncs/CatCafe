//
//  CCAlertVC.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/20.
//

import UIKit

class CCAlertVC: UIViewController {
    
    let containerView = CCAlertContainerView()
    let titleLabel = CCTitleLabel(textAlignment: .center, fontSize: 17)
    let messageLabel = CCBodyLabel(textAlignment: .center)
    let actionButton = CCButton(color: .ccPrimary, title: "Ok", systemImageName: "checkmark.circle")
    var dismissAction: (() -> Void)?
    
    var alertTitle: String?
    var message: String?
    var buttonTitle: String?
    
    let padding: CGFloat = 20
    
    init(title: String, message: String, buttonTitle: String, dismissAction: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.dismissAction = dismissAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubview(containerView)
        containerView.addSubviews(titleLabel, actionButton, messageLabel)
        
        configureContainerView()
        configureTitleLabel()
        configureActionButton()
        configureMessageLabel()
    }
    
    func configureContainerView() {
        containerView.center(inView: view)
        containerView.setDimensions(height: 220, width: 280)
    }
    
    func configureTitleLabel() {
        titleLabel.text = alertTitle ?? "Something went wrong"
        
        titleLabel.anchor(top: containerView.topAnchor,
                          left: containerView.leftAnchor,
                          right: containerView.rightAnchor,
                          paddingTop: padding, paddingLeft: padding, paddingRight: padding,
                          height: 28)
    }
    
    func configureActionButton() {
        actionButton.setTitle(buttonTitle ?? "Ok", for: .normal)
        actionButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        actionButton.anchor(left: containerView.leftAnchor,
                            bottom: containerView.bottomAnchor,
                            right: containerView.rightAnchor,
                            paddingLeft: padding, paddingBottom: padding, paddingRight: padding,
                            height: 44)
    }
    
    func configureMessageLabel() {
        messageLabel.text = message ?? "Unable to complete request"
        messageLabel.numberOfLines = 4
        
        messageLabel.anchor(top: titleLabel.bottomAnchor,
                            left: containerView.leftAnchor,
                            bottom: actionButton.topAnchor,
                            right: containerView.rightAnchor,
                            paddingTop: 8,
                            paddingLeft: padding,
                            paddingBottom: 12,
                            paddingRight: padding)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true) {
            self.dismissAction?()
        }
    }
}
