//
//  CCConstant.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import Firebase

// swiftlint:disable identifier_name
struct CCConstant {
    
    struct LocalStorageKey {
        static let userIdKey = "userIdKey"
        static let hasLogedIn = "hasLogedIn"
    }
    
    struct NotificationName {
        static let updateFeed = NSNotification.Name("updateFeed")
    }

    static let COLLECTION_USERS = Firestore.firestore().collection("users")
    static let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
    static let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
    static let COLLECTION_CAFES = Firestore.firestore().collection("cafes")
    static let COLLECTION_POSTS = Firestore.firestore().collection("posts")
    static let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")
}
