//
//  UIViewController+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import JGProgressHUD

extension UIViewController {
    static let hud = JGProgressHUD(style: .dark)

//    func configureGradientLayer() {
//        let gradient = CAGradientLayer()
//        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
//        gradient.locations = [0, 1]
//        view.layer.addSublayer(gradient)
//        gradient.frame = view.bounds
//    }

    func showLoader(_ show: Bool) {
        view.endEditing(true)

        if show {
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss()
        }
    }

    func showMessage(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in }
        okAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
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
