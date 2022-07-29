//
//  CCDataLoadingController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/24.
//

import UIKit

class CCDataLoadingController: UIViewController {
    
    var containerView: UIView!
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .white
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 0.8
        }
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .ccGrey
        containerView.addSubview(indicator)
        indicator.center(inView: containerView)
        indicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.containerView.removeFromSuperview()
            self.containerView = nil
        }
    }
    
    func showEmptyStateView(with message: String, in view: UIView) {
        // If CCEmptyStateView already exists, then show it
        if let ccEmptyStateView = view.subviews.first(where: { $0 is CCEmptyStateView }) {
            view.bringSubviewToFront(ccEmptyStateView)
            return
        }

        // Otherwise, create it and show it
        let emptyStateView = CCEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
    func hideEmptyStateView(in view: UIView) {
        DispatchQueue.main.async {
            if let ccEmptyStateView = view.subviews.first(where: { $0 is CCEmptyStateView }) {
                ccEmptyStateView.isHidden = true
                return
            }
        }
    }
}
