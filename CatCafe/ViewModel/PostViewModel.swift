//
//  PostViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import Foundation

class PostViewModel {
    
    let post: Post
    
    var ownerImageUrl: URL?
    var ownerUsername: String?
    
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
        if post.likes == 0 {
            return "成為第一個說讚的人"
        } else {
            return "\(post.likes) 個喜歡"
        }
    }
    
    init(post: Post) {
        self.post = post
    }
    
    func fetchUserDataByOwnerUid(completion: @escaping (() -> Void)) {
        UserService.fetchUserBy(uid: post.ownerUid) { [weak self] user in
            self?.ownerUsername = user.username
            self?.ownerImageUrl = URL(string: user.profileImageUrl)
            completion()
        }
    }
    
}
