//
//  CustomAlert.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/2.
//

import UIKit

class CafeInfoAlert {
    struct Constants {
        static let bgAlphaTo: CGFloat = 0.6
        static let alertHeight: CGFloat = 170
    }
    
    var phoneNumber: String?
    var website: String?
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
    
    lazy var phoneButton = makeIconButton(
        imagename: ImageAsset.cellphone.rawValue,
        imageColor: .ccGrey,
        imageWidth: 15,
        imageHeight: 15,
        backgroundColor: .gray5
    )
    lazy var phoneLabel = makeLabel(
        withTitle: "撥打電話",
        font: .systemFont(ofSize: 10, weight: .regular),
        textColor: .darkGray
    )
    lazy var phoneStack = UIStackView(arrangedSubviews: [phoneButton, phoneLabel])
    
    lazy var websiteButton = makeIconButton(
        imagename: ImageAsset.website.rawValue,
        imageColor: .ccGrey,
        imageWidth: 15,
        imageHeight: 15,
        backgroundColor: .gray5
    )
    lazy var websiteLabel = makeLabel(
        withTitle: "網站",
        font: .systemFont(ofSize: 10, weight: .regular),
        textColor: .darkGray
    )
    lazy var websiteStack = UIStackView(arrangedSubviews: [websiteButton, websiteLabel])
    lazy var baseStackView = UIStackView(arrangedSubviews: [phoneStack, websiteStack])

    lazy var button = makeTitleButton(
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
    
    // swiftlint:disable all
    func showAlert(with title: String?,
                   phoneNumber: String,
                   website: String,
                   on viewController: UIViewController
    ) {
        guard let targetView = viewController.view else { return }
        mytargetView = targetView
        self.viewController = viewController
        self.phoneNumber = phoneNumber
        self.website = website
        
        targetView.addSubview(bgView)
        targetView.addSubview(alertView)
        bgView.frame = targetView.bounds
        alertView.frame = CGRect(x: 40,
                                 y: -300,
                                 width: targetView.frame.size.width-100,
                                 height: Constants.alertHeight)
        
        // alertView
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .ccGrey
        alertView.addSubview(titleLabel)
        titleLabel.anchor(top: self.alertView.topAnchor,
                          left: self.alertView.leftAnchor,
                          right: self.alertView.rightAnchor,
                          paddingTop: 16)
        
        button.addTarget(viewController, action: #selector(dissmissAlert), for: .touchUpInside)
        alertView.addSubview(button)
        button.centerX(inView: self.alertView)
        button.anchor(bottom: self.alertView.bottomAnchor, paddingBottom: 16)
        
        phoneButton.addTarget(viewController, action: #selector(makePhoneCall), for: .touchUpInside)
        phoneButton.layer.cornerRadius = 30/2
        phoneButton.setDimensions(height: 30, width: 30)
        websiteButton.addTarget(viewController, action: #selector(gotoWebsite), for: .touchUpInside)
        websiteButton.layer.cornerRadius = 30/2
        websiteButton.setDimensions(height: 30, width: 30)
        phoneStack.axis = .vertical
        phoneStack.alignment = .center
        phoneStack.distribution = .equalSpacing
        phoneStack.spacing = 8
        websiteStack.axis = .vertical
        websiteStack.alignment = .center
        websiteStack.distribution = .equalSpacing
        websiteStack.spacing = 8
        baseStackView.alignment = .center
        baseStackView.distribution = .equalSpacing
        baseStackView.spacing = 24
        alertView.addSubview(baseStackView)
        baseStackView.anchor(bottom: button.topAnchor, paddingBottom: 16)
        baseStackView.centerX(inView: self.alertView)
        
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
    
    @objc func makePhoneCall() {
        guard let phoneNumber = phoneNumber, !phoneNumber.isEmpty else {
            guard let viewController = viewController else { return }
            AlertHelper.showMessage(title: "Oops", message: "無電話", buttonTitle: "OK", over: viewController)
            return
        }
        
        if let phoneCallURL = URL(string: "tel://" + phoneNumber) {
            let application: UIApplication = UIApplication.shared
            if application.canOpenURL(phoneCallURL) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    @objc func gotoWebsite() {
        guard let website = website, !website.isEmpty else {
            guard let viewController = viewController else { return }
            AlertHelper.showMessage(title: "Oops", message: "無網站", buttonTitle: "OK", over: viewController)
            return
        }
                
        let controller = WebsiteController()
        controller.website = website
        let navController = makeNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        viewController?.present(navController, animated: true)
    }
    
}
