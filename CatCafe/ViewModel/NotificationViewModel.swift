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
            attributes: [.font: UIFont.notoMedium(size: 12)]
        )
        attributedText.append(
            NSAttributedString(
                string: message,
                attributes: [.font: UIFont.notoRegular(size: 12)]
            ))
        attributedText.append(
            NSAttributedString(
                string: "  2m",
                attributes: [
                    .font: UIFont.notoRegular(size: 10),
                    .foregroundColor: UIColor.lightGray]
            ))
        return attributedText
    }
    
    var photoUrl: URL? {
        switch notification.notiType {
        case .like:
            return mediaUrl
        case .follow:
            return nil
        case .comment:
            return mediaUrl
        }
    }
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var shouldHidePostImage: Bool {
        return self.notification.notiType == .follow
    }
}
