//
//  DeleteAccountAlert.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/12.
//

import UIKit
import MessageUI

class DeleteAccountAlert {
    
    struct Constants {
        static let bgAlphaTo: CGFloat = 0.6
        static let alertHeight: CGFloat = 170
    }
    
    var viewController: UIViewController?

    // MARK: - View
    private var mytargetView: UIView?
    
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var titleLabel = UILabel()
    lazy var descriptionLabel = UILabel()

    lazy var cancelButton = makeTitleButton(
        withText: "取消",
        font: .systemFont(ofSize: 13, weight: .regular),
        kern: 1,
        foregroundColor: .ccPrimary,
        backgroundColor: .white,
        insets: .init(top: 5, left: 16, bottom: 5, right: 16),
        cornerRadius: 5,
        borderWidth: 1,
        borderColor: .ccPrimary
    )
    
    lazy var okButton = makeTitleButton(
        withText: "確定",
        font: .systemFont(ofSize: 13, weight: .regular),
        kern: 1,
        foregroundColor: .ccSecondary,
        backgroundColor: .white,
        insets: .init(top: 5, left: 16, bottom: 5, right: 16),
        cornerRadius: 5,
        borderWidth: 1,
        borderColor: .ccSecondary
    )

    // swiftlint:disable all
    func showAlert(on viewController: UIViewController) {
        
        guard let targetView = viewController.view else { return }
        mytargetView = targetView
        self.viewController = viewController
      
        targetView.addSubview(bgView)
        targetView.addSubview(alertView)
        bgView.frame    = targetView.bounds
        alertView.frame = CGRect(
            x: 40,
            y: -300,
            width: targetView.frame.width-100,
            height: Constants.alertHeight
        )
        
        // alertView
        titleLabel.text = "注意"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .ccGrey
        alertView.addSubview(titleLabel)
        titleLabel.anchor(top: self.alertView.topAnchor,
                          left: self.alertView.leftAnchor,
                          right: self.alertView.rightAnchor,
                          paddingTop: 32)
        
        descriptionLabel.text = "我們將刪除您的帳號"
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 1
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .ccGrey
        
        alertView.addSubview(descriptionLabel)
        descriptionLabel.centerX(inView: self.alertView)
        descriptionLabel.centerY(inView: self.alertView)
        
        cancelButton.addTarget(viewController, action: #selector(dissmissAlert), for: .touchUpInside)
        alertView.addSubview(cancelButton)
        cancelButton.anchor(
            left: self.alertView.leftAnchor,
            bottom: self.alertView.bottomAnchor,
            paddingLeft: self.alertView.frame.width / 5,
            paddingBottom: 16
        )
        
        okButton.addTarget(viewController, action: #selector(deleteAccount), for: .touchUpInside)
        alertView.addSubview(okButton)
        okButton.anchor(
            bottom: self.alertView.bottomAnchor,
            right: self.alertView.rightAnchor,
            paddingBottom: 16,
            paddingRight: self.alertView.frame.width / 5
        )
        
        // bgView
        UIView.animate(withDuration: 0.25, animations: {
            self.bgView.alpha = Constants.bgAlphaTo
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alertView.center = targetView.center
                })
            }
        })
    }
    // swiftlint:enable all
        
    @objc func dissmissAlert() {
        guard let targetView = mytargetView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(
                x: 40,
                y: targetView.frame.size.height,
                width: targetView.frame.size.width-100,
                height: Constants.alertHeight
            )
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.bgView.alpha = 0
                }, completion: { _ in
                    self.alertView.removeFromSuperview()
                    self.bgView.removeFromSuperview()
                })
            }
        })
    }
    
    @objc func deleteAccount() {}
        
    
}
