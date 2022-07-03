//
//  JGProgressHUDWrapper.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import JGProgressHUD

enum HUDType {
    case success(String)
    case failure(String)
}

class CCProgressHUD {

    static let hud = JGProgressHUD(style: .dark)

    static var view: UIView {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        let viewController = window!.rootViewController
        return (viewController?.view)!
    }

    static func show(type: HUDType) {
        switch type {
        case .success(let text):
            showSuccess(text: text)
        case .failure(let text):
            showFailure(text: text)
        }
    }

    static func showSuccess(text: String = "success") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showSuccess(text: text)
            }
            return
        }
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: view)
        hud.dismiss(afterDelay: 1.5)
    }

    static func showFailure(text: String = "Failure") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showFailure(text: text)
            }
            return
        }
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: view)
        hud.dismiss(afterDelay: 1.5)
    }

    static func show() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                show()
            }
            return
        }
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.textLabel.text = "Loading"
        hud.show(in: view)
    }

    static func dismiss() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                dismiss()
            }
            return
        }
        hud.dismiss()
    }
}
