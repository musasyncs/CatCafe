//
//  NotificationViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

struct NotificationViewModel {
    
    private let notification: Notification
    
    var profileImageUrl: URL?
    var username: String?
    var mediaUrl: URL?
    
    var notificationMessage: NSAttributedString {
        guard let username = username else { return NSAttributedString() }
        let message = notification.notiType.notificationMessage
        
        let attributedText = NSMutableAttributedString(
            string: username,
            attributes: [.font: UIFont.notoMedium(size: 14)]
        )
        attributedText.append(
            NSAttributedString(
                string: message,
                attributes: [.font: UIFont.notoRegular(size: 14)]
            ))
        attributedText.append(
            NSAttributedString(
                string: "  2m",
                attributes: [
                    .font: UIFont.notoRegular(size: 12),
                    .foregroundColor: UIColor.lightGray]
            ))
        return attributedText
    }
    
    var photoUrl: URL? {
        switch notification.notiType {
        case .like:
            return mediaUrl
        case .comment:
            return mediaUrl
        case .follow:
            return nil
        }
    }
    
    init(notification: Notification) {
        self.notification = notification
    }
}
