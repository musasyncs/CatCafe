//
//  CCConstant.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import Firebase

// swiftlint:disable identifier_name
struct CCConstant {
    static let COLLECTION_USERS = Firestore.firestore().collection("users")
    static let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
    static let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
}
