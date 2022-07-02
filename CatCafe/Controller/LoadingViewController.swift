//
//  LoadingViewController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/2.
//

import UIKit

class LoadingViewController: UIViewController {
    
    var loadingImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(loadingImageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingImageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.animate()
        })
    }
    
    private func animate() {
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.size.width * 2
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.loadingImageView.frame = CGRect(x: -(diffX/2), y: diffY/2, width: size, height: size)
            self.loadingImageView.alpha = 0
        })
        
        UIView.animate(withDuration: 1.5, animations: {
            self.loadingImageView.alpha = 0
        }, completion: { done in
            if done {
                delay(durationInSeconds: 0.5) {
                    Presentaion.shared.show(viewController: .mainTabBarController)
                }
            }
        })
    }

}

func delay(durationInSeconds secound: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + secound, execute: completion)
}

class Presentaion {
    static let shared = Presentaion()
    
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
            UIView.transition(with: window,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: nil, completion: nil)
        }
    }
}
