//
//  CCConstant.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import Firebase

// swiftlint:disable identifier_name
struct CCConstant {
    
    struct NotificationName {
        static let updateFeed = Notification.Name("updateFeed")
    }
    
    // User
    static let COLLECTION_USERS = Firestore.firestore().collection("users")
    static let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
    static let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
    
    // Cafe
    static let COLLECTION_CAFES = Firestore.firestore().collection("cafes")
    
    // Post
    static let COLLECTION_POSTS = Firestore.firestore().collection("posts")
}
