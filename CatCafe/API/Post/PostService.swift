//
//  PostService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import UIKit
import Firebase

struct PostService {
    
    // MARK: - Upload image post
    
    static func uploadImagePost(
        caption: String,
        postImage: UIImage,
        cafeId: String,
        cafeName: String,
        completion: @escaping(FirestoreCompletion)
    ) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUplader.uploadPostImage(image: postImage) { imageUrlString in
            let dic: [String: Any] = [
                "ownerUid": uid,
                "mediaType": 0,
                "mediaUrlString": imageUrlString,
                "caption": caption,
                "likes": 0,
                "timestamp": Timestamp(date: Date()),
                "cafeId": cafeId,
                "cafeName": cafeName
            ]
            CCConstant.COLLECTION_POSTS.addDocument(data: dic, completion: completion)
        }
    }
    
    // MARK: - Fetch all posts
    
    static func fetchPosts(completion: @escaping(([Post]) -> Void)) {
        CCConstant.COLLECTION_POSTS
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map { Post(postId: $0.documentID, dic: $0.data()) }
            completion(posts)
        }
    }
    
    // MARK: - Fetch posts by uid
    
    static func fetchPosts(forUser uid: String, completion: @escaping(([Post]) -> Void)) {
        let query = CCConstant.COLLECTION_POSTS
            .whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            var posts = documents.map { Post(postId: $0.documentID, dic: $0.data()) }
            
            posts.sort { (post1, post2) -> Bool in
                return post1.timestamp.seconds > post2.timestamp.seconds
            }
            
            completion(posts)
        }
    }
}
