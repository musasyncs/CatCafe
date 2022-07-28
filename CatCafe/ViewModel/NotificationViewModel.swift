//
//  NotificationViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

struct NotificationViewModel {
    var notification: Notification
    
    var profileImageUrlString: String?
    var username: String?
    var mediaUrlString: String?
    
    var notificationMessage: NSAttributedString {
        guard let username = username else { return NSAttributedString() }
        let message = notification.notiType.notificationMessage
        
        let attributedText = NSMutableAttributedString(
            string: username,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.ccGrey
            ]
        )
        attributedText.append(
            NSAttributedString(
                string: message,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.ccGrey
                ]
            ))
        attributedText.append(
            NSAttributedString(
                string: "  \(timestampText ?? "")",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor.lightGray]
            ))
        return attributedText
    }
    
    var photoUrlString: String? {
        switch notification.notiType {
        case .like:
            return mediaUrlString
        case .follow:
            return nil
        case .comment:
            return mediaUrlString
        }
    }
    
    var shouldHidePostImage: Bool {
        return self.notification.notiType == .follow
    }
    
    var followButtonText: String {
        return notification.userIsFollowed ? "追蹤中" : "追蹤"
    }
    
    var followButtonBackgroundColor: UIColor {
        return notification.userIsFollowed ? .white : .ccPrimary
    }
    
    var followButtonTextColor: UIColor {
        return notification.userIsFollowed ? .ccGrey : .white
    }
    
    var borderLineColor: CGColor {
        if notification.userIsFollowed {
            return UIColor.ccGreyVariant.cgColor
        } else {
            return UIColor.ccPrimary.cgColor
        }
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
