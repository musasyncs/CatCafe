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
        let layer = CAGradientLayer()
        layer.frame = view.bounds
        layer.colors = [
            UIColor.rgb(hex: "8BB5FF").withAlphaComponent(0.2).cgColor,
            UIColor.rgb(hex: "E1FBFF").withAlphaComponent(0.05).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.3, y: 0)
        layer.endPoint = CGPoint(x: 0.7, y: 1)
        layer.locations = [-0.2, 1.2]
        view.layer.insertSublayer(layer, at: 0)
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
    
    func showHud() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.showHud()
            }
            return
        }
        UIViewController.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        UIViewController.hud.textLabel.text = "Loading"
        UIViewController.hud.show(in: view)
    }
    
    func dismissHud() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.dismissHud()
            }
            return
        }
        UIViewController.hud.dismiss()
    }
    
    func showSuccess(text: String = "成功") {
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
    
    func showFailure(text: String = "失敗") {
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
    
    // MARK: - Present
    func presentWebVC(with urlString: String) {
        let controller = WebViewController()
        controller.url = urlString
        present(controller, animated: true)
    }
    
}
