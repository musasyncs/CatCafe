//
//  MeetViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit
import Firebase

struct MeetViewModel {
    
    var meet: Meet
    var comments = [Comment]()
    
    // ===
    var titleText: String? {
        return meet.title
    }
    
    var descriptionLabel: String? {
        return meet.caption
    }
    
    var peopleCount: Int {
        return meet.peopleCount
    }
    
    var commentCount: Int {
        return comments.count
    }
    
    var infoText: String? {
        return "\(peopleCount)人報名｜\(commentCount)則留言"
    }
    
    // ===
    
    var ownerImageUrl: URL?
    var ownerUsername: String?
    
    var locationText: String? {
        return meet.cafeName
    }
    
    var mediaUrl: URL? {
        return URL(string: meet.mediaUrlString)
    }
    
    var caption: String {
        return meet.caption
    }
    
    var likes: Int {
        return meet.likes
    }
    var likesLabelText: String {
        return "\(likes)"
    }
    var likeButtonImage: UIImage? {
        let imageName = meet.isLiked ? "like_selected" : "like_unselected"
        return UIImage(named: imageName)
    }
    var likeButtonTintColor: UIColor {
        return meet.isLiked ? .systemRed : .black
    }
    
    var timestampText: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: meet.timestamp.dateValue())
    }
    
    var attendButtonBackgroundColor: UIColor {
        let currentUid = LocalStorage.shared.getUid()
        if meet.ownerUid == currentUid {
            return .systemGray5
        } else {
            if meet.isAttended {
                return .systemGray5
            } else {
                return .systemBrown
            }
        }
    }
    
    var attendButtonEnabled: Bool {
        let currentUid = LocalStorage.shared.getUid()
        if meet.ownerUid == currentUid {
            return false
        } else {
            if meet.isAttended {
                return false
            } else {
                return true
            }
        }
    }

    init(meet: Meet) {
        self.meet = meet
    }
    
}
