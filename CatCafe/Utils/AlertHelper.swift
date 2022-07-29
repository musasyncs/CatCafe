//
//  AlertHelper.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/19.
//

import UIKit

class AlertHelper {
    
    static func showMessage(title: String,
                            message: String,
                            buttonTitle: String,
                            dismissAction: (() -> Void)? = nil,
                            over viewController: UIViewController
    ) {
        let alertVC = CCAlertVC(title: title,
                                message: message,
                                buttonTitle: buttonTitle,
                                dismissAction: dismissAction)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        viewController.present(alertVC, animated: true)
    }
    
    static func showDefaultError(over viewController: UIViewController) {
        let alertVC = CCAlertVC(title: "Something Went Wrong",
                                message: "We were unable to complete your task at this time. Please try again.",
                                buttonTitle: "Ok")
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        viewController.present(alertVC, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alertVC.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // For report
    static func showActionSheet(
        forPost post: Post,
        showReportAlert: @escaping (Post) -> Void,
        over viewController: UIViewController
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Report
        let reportAction = UIAlertAction(title: "Report post", style: .default) { (_) in
            showReportAlert(post)
        }
        reportAction.setValue(SFSymbols.shield, forKey: "image")
        reportAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(reportAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        cancelAction.setValue(SFSymbols.arrow_up_left, forKey: "image")
        cancelAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
    
    static func showReportAlert(
        forPost post: Post,
        over viewController: UIViewController
    ) {
        let alert = UIAlertController(
            title: "Please select a problem",
            message: "",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Nudity", style: .default, handler: {  _ in
            sendReport(postId: post.postId, message: "Nudity", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Violence", style: .default, handler: {  _ in
            sendReport(postId: post.postId, message: "Violence", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Harassment", style: .default, handler: { _ in
            sendReport(postId: post.postId, message: "Harassment", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Suicide or self-injury", style: .default, handler: { _ in
            sendReport(postId: post.postId, message: "Suicide or self-injury", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "False information", style: .default, handler: { _ in
            sendReport(postId: post.postId, message: "False information", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Spam", style: .default, handler: { _ in
            sendReport(postId: post.postId, message: "Spam", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Hate speech", style: .default, handler: { _ in
            sendReport(postId: post.postId, message: "Hate speech", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Terrorism", style: .default, handler: { _ in
            sendReport(postId: post.postId, message: "Terrorism", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Something else", style: .default, handler: { _ in
            sendReport(postId: post.postId, message: "Something else", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true)
    }
    
    static func sendReport(
        postId: String,
        message: String,
        over viewController: UIViewController
    ) {
        ReportService.shared.sendReport(postId: postId, message: message) { result in
            switch result {
            case .success:
                showMessage(title: "Thanks for reporting this post",
                            message: "We will review this post and remove anything that doesn't follow our standards",
                            buttonTitle: "OK",
                            over: viewController)
            case .failure:
                DispatchQueue.main.async {
                    showDefaultError(over: viewController)
                }
            }
        }
    }
    
}
