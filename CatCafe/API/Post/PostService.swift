//
//  PostService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import UIKit
import Firebase

struct PostService {
    
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
    
    static func fetchPosts(completion: @escaping(([Post]) -> Void)) {
        CCConstant.COLLECTION_POSTS.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map { Post(postId: $0.documentID, dic: $0.data()) }
            completion(posts)
        }
    }
}
