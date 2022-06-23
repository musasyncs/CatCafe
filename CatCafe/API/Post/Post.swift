//
//  Post.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import Firebase

struct Post {
    let cafeId: String
    let cafeName: String
    let caption: String
    var likes: Int
    let mediaType: Int
    let mediaUrlString: String
    var ownerUid: String
    let timestamp: Timestamp
    
    var postId: String
    var isLiked = false
        
    init(postId: String, dic: [String: Any]) {
        self.cafeId = dic["cafeId"] as? String ?? ""
        self.cafeName = dic["cafeName"] as? String ?? ""
        self.caption = dic["caption"] as? String ?? ""
        self.likes = dic["likes"] as? Int ?? 0
        self.mediaType = dic["mediaType"] as? Int ?? 0
        self.mediaUrlString = dic["mediaUrlString"] as? String ?? ""
        self.ownerUid = dic["ownerUid"] as? String ?? ""
        self.timestamp = dic["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.postId = postId
    }
    
}
