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
        
    var ownerImageUrlString: String? {
        return meet.user.profileImageUrlString
    }
    
    var ownerUsername: String? {
        return meet.user.username
    }
    
    var locationText: String? {
        return meet.cafeName
    }
    
    var mediaUrlString: String {
        return meet.mediaUrlString
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
        let imageName = meet.isLiked
        ? ImageAsset.like_selected.rawValue
        : ImageAsset.like_unselected.rawValue
        return UIImage(named: imageName)
    }
    var likeButtonTintColor: UIColor {
        return meet.isLiked ? .systemRed : .ccGrey
    }
    
    var timestampText: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: meet.timestamp.dateValue())
    }
    
    var attendButtonBackgroundColor: UIColor {
        let currentUid = LocalStorage.shared.getUid()
        if meet.ownerUid == currentUid {
            return .lightGray
        } else {
            if meet.isAttended {
                return .lightGray
            } else {
                return .ccPrimary
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
    
    var infoText: String? {
        return "\(peopleCount)人報名｜\(meet.commentCount)則留言"
    }
    
    var shouldHidePeopleButton: Bool {
        guard let currentUid = LocalStorage.shared.getUid() else { return true }
        if meet.ownerUid == currentUid {
            return false
        } else {
            return true
        }
    }
    
    // ===

    init(meet: Meet) {
        self.meet = meet
    }
    
}
