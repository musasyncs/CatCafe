//
//  PresentaionManager.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/19.
//

import UIKit

class PresentaionManager {
    
    static let shared = PresentaionManager()
    private init() {}
    
    enum ViewController {
        case mainTabBarController
    }
    
    func show(viewController: ViewController) {
        var contoller: UIViewController
        
        switch viewController {
        case .mainTabBarController:
            contoller = MainTabController()
        }
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = contoller
            UIView.transition(
                with: window,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: nil, completion: nil
            )
        }
    }
    
}
