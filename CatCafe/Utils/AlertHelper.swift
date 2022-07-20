//
//  AlertHelper.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/19.
//

import UIKit

extension UIAlertAction {
    
    static var okAction: UIAlertAction {
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        okAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        return okAction
    }
    
}

class AlertHelper {
    
    static func showMessage(
        title: String?,
        message: String?,
        over viewController: UIViewController
    ) {
        assert((title ?? message) != nil, "Title OR message must be passed in")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.okAction)
        viewController.present(alert, animated: true)
    }
    
    static func showActionSheet(
        forPost post: Post,
        showReportAlert: @escaping (Post) -> (),
        over viewController: UIViewController
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Report
        let reportAction = UIAlertAction(title: "Report post", style: .default) { (_) in
            showReportAlert(post)
        }
        reportAction.setValue(UIImage(systemName: "exclamationmark.shield"), forKey: "image")
        reportAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(reportAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        cancelAction.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
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
                showMessage(
                    title: "Thanks for reporting this post",
                    message: "We will review this post and remove anything that doesn't follow our standards as quickly as possible",
                    over: viewController)
            case .failure(let error):
                showErrorMessage(message: error.localizedDescription, over: viewController)
            }
        }
    }
    
    static func showErrorMessage(message: String?, over viewController: UIViewController) {
        assert((message) != nil, "Title OR message must be passed in")
        
        let alert = UIAlertController(title: "網路異常", message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
