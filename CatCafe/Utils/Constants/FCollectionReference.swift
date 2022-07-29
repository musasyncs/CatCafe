//
//  FCollectionReference.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/28.
//

import FirebaseFirestore

enum FCollectionReference: String {
    case users
    case followers
    case following
    case cafes
    case posts
    case notifications
    case meets
    
    case recent
    case messages
    case typing
    
    case reports
}

func firebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
