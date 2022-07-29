//
//  PostViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import UIKit

struct PostViewModel {
    var post: Post

    var ownerImageUrlString: String? {
        return post.user.profileImageUrlString
    }
    var ownerUsername: String? {
        return post.user.username
    }
    var locationText: String? {
        return post.cafeName
    }
    var shouldHideFunctionButton: Bool {
        if post.ownerUid == UserService.shared.currentUser?.uid {
            return true
        } else {
            return false
        }
    }

    var mediaUrlString: String {
        return post.mediaUrlString
    }
    
    func makeCaptionText() -> NSAttributedString {
        guard let ownerUsername = ownerUsername else {
            return NSAttributedString(string: "")
        }
        
        let attrString = NSMutableAttributedString(
            string: "\(ownerUsername) ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.ccGrey
            ])
        attrString.append(NSAttributedString(
            string: post.caption,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor.ccGrey
            ]))
        
        return attrString
    }
    
    var likes: Int {
        return post.likes
    }
    var likesLabelText: String {
        return "\(post.likes)"
    }
    var likeButtonImage: UIImage? {
        let imageName = post.isLiked
        ? ImageAsset.like_selected.rawValue
        : ImageAsset.like_unselected.rawValue        
        return UIImage(named: imageName)
    }
    var likeButtonTintColor: UIColor {
        return post.isLiked ? .systemRed : .ccGrey
    }
        
    var commentCountText: String? {
        return "\(post.commentCount)"
    }
    
    var timestampText: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: post.timestamp.dateValue(), to: Date())
    }
    
    init(post: Post) {
        self.post = post
    }
}
