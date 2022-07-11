//
//  User.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    let email: String
    let fullname: String
    let profileImageUrlString: String
    let username: String
    let bioText: String
    let uid: String
    var blockedUsers: [String]

    var isFollowed = false
    var isBlocked = false
    var stats: UserStats!
    var isCurrentUser: Bool {
        LocalStorage.shared.getUid() == uid
    }
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.fullname = dic["fullname"] as? String ?? ""
        self.profileImageUrlString = dic["profileImageUrlString"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.bioText = dic["bioText"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        
        self.stats = UserStats(followers: 0, following: 0, postCounts: 0)
        self.blockedUsers = dic["blockedUsers"] as? [String] ?? []
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.uid == rhs.uid
    }
    
}

struct UserStats: Codable {
    let followers: Int
    let following: Int
    let postCounts: Int
}
