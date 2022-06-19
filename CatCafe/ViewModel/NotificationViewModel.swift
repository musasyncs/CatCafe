//
//  NotificationViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

struct NotificationViewModel {
    
    var notification: Notification
    
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
                string: "  \(timestampText ?? "")",
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
    
    var shouldHidePostImage: Bool {
        return self.notification.notiType == .follow
    }
    
    var followButtonText: String {
        return notification.userIsFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return notification.userIsFollowed ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return notification.userIsFollowed ? .black : .white
    }
    
    var timestampText: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: notification.timestamp.dateValue(), to: Date())
    }
    
    init(notification: Notification) {
        self.notification = notification
    }
    
}
