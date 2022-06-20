//
//  PostViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import Foundation
import UIKit

struct PostViewModel {
    
    var post: Post
    
    var ownerImageUrl: URL?
    var ownerUsername: String?
    
    var locationText: String? {
        return post.cafeName
    }
    
    var mediaUrl: URL? {
        return URL(string: post.mediaUrlString)
    }
    
    var caption: String {
        return post.caption
    }
    
    var likes: Int {
        return post.likes
    }
    var likesLabelText: String {
        if post.likes == 1 {
            return "\(post.likes) like"
        } else {
            return "\(post.likes) likes"
        }
    }
    var likeButtonImage: UIImage? {
        let imageName = post.isLiked ? "like_selected" : "like_unselected"
        return UIImage(named: imageName)
    }
    var likeButtonTintColor: UIColor {
        return post.isLiked ? .systemRed : .black
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
