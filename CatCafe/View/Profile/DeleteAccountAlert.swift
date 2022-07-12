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

    lazy var okButton = makeTitleButton(
        withText: "確定",
        font: .systemFont(ofSize: 13, weight: .regular),
        kern: 1,
        foregroundColor: .ccPrimary,
        backgroundColor: .white,
        insets: .init(top: 5, left: 16, bottom: 5, right: 16),
        cornerRadius: 5,
        borderWidth: 1,
        borderColor: .ccPrimary
    )
    
    lazy var emailButton = makeTitleButton(
        withText: "rubato.cw@gmail.com",
        font: .systemFont(ofSize: 14, weight: .regular),
        kern: 1,
        foregroundColor: .ccSecondary,
        backgroundColor: .clear
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
            width: targetView.frame.size.width-100,
            height: Constants.alertHeight
        )
        
        // alertView
        titleLabel.text = "欲刪除帳號請聯絡開發者："
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .ccGrey
        alertView.addSubview(titleLabel)
        titleLabel.anchor(top: self.alertView.topAnchor,
                          left: self.alertView.leftAnchor,
                          right: self.alertView.rightAnchor,
                          paddingTop: 32)
        
        okButton.addTarget(viewController, action: #selector(dissmissAlert), for: .touchUpInside)
        alertView.addSubview(okButton)
        okButton.centerX(inView: self.alertView)
        okButton.anchor(bottom: self.alertView.bottomAnchor, paddingBottom: 16)
        
        emailButton.addTarget(viewController, action: #selector(sendEmail), for: .touchUpInside)
        alertView.addSubview(emailButton)
        emailButton.centerX(inView: self.alertView)
        emailButton.centerY(inView: self.alertView)
        
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
    
    @objc func sendEmail() {
        guard let viewController = viewController else { return }
        
        guard MFMailComposeViewController.canSendMail() else {
            viewController.showMessage(withTitle: "Oops", message: "無法聯絡開發者")
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = viewController as? MFMailComposeViewControllerDelegate
        composer.setToRecipients(["rubato.cw@gmail.com"])
        composer.setSubject("Please help")
        composer.setMessageBody("Please help delete my account!", isHTML: false)
        viewController.present(composer, animated: true)
    }
    
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
    
}
