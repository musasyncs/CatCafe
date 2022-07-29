//
//  LoadingViewController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/2.
//

import UIKit

class LoadingViewController: UIViewController {
    
    // MARK: - View
    var loadingImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        imageView.image = UIImage.asset(.logo)
        return imageView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ccGrey
        view.addSubview(loadingImageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingImageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.animateLoadingImageView()
        })
    }
    
    // MARK: - Helper
    private func animateLoadingImageView() {
        UIView.animate(withDuration: 0.5, animations: {
            let size = self.view.frame.width * 1.3
            let diffX = size - self.view.frame.width
            let diffY = self.view.frame.height - size
            self.loadingImageView.frame = CGRect(x: -(diffX / 2), y: diffY / 2, width: size, height: size)
            self.loadingImageView.alpha = 0
        })
        
        UIView.animate(withDuration: 0.5) {
            self.loadingImageView.alpha = 0
        } completion: { [weak self] success in
            if success {
                self?.delay(durationInSeconds: 0.5) {
                    PresentaionManager.shared.show(viewController: .mainTabBarController)
                }
            }
        }
    }
    
    private func delay(durationInSeconds secound: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + secound, execute: completion)
    }
    
}
