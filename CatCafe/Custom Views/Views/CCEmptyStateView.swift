//
//  CCEmptyStateView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/24.
//

import UIKit

class CCEmptyStateView: UIView {
    
    let messageLabel = CCTitleLabel(textAlignment: .center, fontSize: 23)
    let logoImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(message: String) {
        self.init(frame: .zero)
        messageLabel.text = message
    }
    
    private func configure() {
        backgroundColor = .white
        addSubviews(messageLabel, logoImageView)
        setupMessageLabel()
        setupLogoImageView()
    }
    
    private func setupMessageLabel() {
        messageLabel.numberOfLines = 3
        messageLabel.textColor = .gray2
        
        let labelCenterYConst: CGFloat = DeviceTypes.isiPhone8Standard
        || DeviceTypes.isiPhoneSE
        || DeviceTypes.isiPhone8Zoomed ? -170 : -150
        
        messageLabel.anchor(left: leftAnchor,
                            right: rightAnchor,
                            paddingLeft: 40, paddingRight: 40,
                            height: 200)
        messageLabel.centerY(inView: self, constant: labelCenterYConst)
    }
    
    private func setupLogoImageView() {
        logoImageView.image = UIImage.asset(.logo)
        logoImageView.alpha = 0.2
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoBottomConstant: CGFloat = 60

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 170),
            logoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: logoBottomConstant)
        ])
    }
}
