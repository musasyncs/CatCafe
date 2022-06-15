//
//  User.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Foundation
import Firebase

struct User {
    let email: String
    let fullname: String
    let profileImageUrl: String
    let username: String
    let uid: String
    
    var isFollowed = false
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.fullname = dic["fullname"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
    }
}
