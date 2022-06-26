//
//  UIViewController+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import JGProgressHUD

extension UIViewController {
   
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

    func showMessage(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in }
        okAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
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
