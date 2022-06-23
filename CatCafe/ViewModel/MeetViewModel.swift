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
    var people = [User]()
    
    // ===
    var titleText: String? {
        return meet.title
    }
    
    var descriptionLabel: String? {
        return meet.caption
    }
    
    var peopleCount: Int {
        return people.count
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
    
    init(meet: Meet) {
        self.meet = meet
    }
    
}
