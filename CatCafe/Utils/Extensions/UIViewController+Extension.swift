//
//  UIViewController+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import JGProgressHUD

enum NavBackgroundType {
    case defaultBackground
    case transparentBackground
    case opaqueBackground
}

extension UIViewController {
    
    // MARK: - Gradient Background
    func createGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.rgb(hex: "8BB5FF").withAlphaComponent(0.05).cgColor,
            UIColor.rgb(hex: "E1FBFF").withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.3, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.7, y: 1)
        gradientLayer.locations = [-0.2, 1.2]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - NavigationBar
    func setupCustomNavBar(
        backgroundType: NavBackgroundType,
        shouldSetCustomBackImage: Bool,
        backIndicatorImage: UIImage?
    ) {
        let appearance = UINavigationBarAppearance()
    
        if backgroundType == .opaqueBackground {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
        } else if backgroundType == .transparentBackground {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .white
        }
        
        // navbar 返回按鈕自訂圖片
        if shouldSetCustomBackImage {
            let image = backIndicatorImage?.withRenderingMode(.alwaysOriginal)
            appearance.setBackIndicatorImage(image, transitionMaskImage: image)
        }
        // 返回按鈕 字型樣式(clear color)
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = backButtonAppearance
        
        // clear shadow color
        appearance.shadowColor = .clear
 
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - JGProgressHUD
    static let hud = JGProgressHUD(style: .dark)
    
    enum HUDType {
        case success(String)
        case failure(String)
    }
    
    func show(type: HUDType) {
        switch type {
        case .success(let text):
            showSuccess(text: text)
        case .failure(let text):
            showFailure(text: text)
        }
    }
    
    func show() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.show()
            }
            return
        }
        UIViewController.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        UIViewController.hud.textLabel.text = "Loading"
        UIViewController.hud.show(in: view)
    }
    
    func dismiss() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.dismiss()
            }
            return
        }
        UIViewController.hud.dismiss()
    }
    
    func showSuccess(text: String = "success") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.showSuccess(text: text)
            }
            return
        }
        UIViewController.hud.textLabel.text = text
        UIViewController.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        UIViewController.hud.show(in: view)
        UIViewController.hud.dismiss(afterDelay: 1.5)
    }
    
    func showFailure(text: String = "Failure") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.showFailure(text: text)
            }
            return
        }
        UIViewController.hud.textLabel.text = text
        UIViewController.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        UIViewController.hud.show(in: view)
        UIViewController.hud.dismiss(afterDelay: 1.5)
    }
    
    // MARK: - UIAlertController
    func showMessage(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in }
        okAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    // MARK: - Add / Remove child view controller
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
