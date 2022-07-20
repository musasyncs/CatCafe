//
//  Comment.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import FirebaseFirestore

struct Comment {
    let comment: String
    let mediaType: Int
    let mediaUrlString: String
    let timestamp: Timestamp
    let uid: String
    
    let user: User
    
    init(user: User, dic: [String: Any]) {
        self.comment        = dic["comment"] as? String ?? ""
        self.mediaType      = dic["mediaType"] as? Int ?? 0
        self.mediaUrlString = dic["mediaUrlString"] as? String ?? ""
        self.timestamp      = dic["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.uid            = dic["uid"] as? String ?? ""
        
        self.user = user
    }
}
