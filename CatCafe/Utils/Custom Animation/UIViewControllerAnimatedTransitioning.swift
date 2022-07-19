//
//  CustomAnimationDismisser.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval = 0.25
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        containerView.addSubview(toView)
        toView.frame.origin = CGPoint(x: -toView.frame.width, y: 0)
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
            toView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
    
}

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval = 0.25
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else { return }

        containerView.addSubview(fromView)
        fromView.frame.origin = .zero
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
            fromView.frame.origin = CGPoint(x: -fromView.frame.width, y: 0)
        }, completion: { (_) in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
        
    }
    
}
