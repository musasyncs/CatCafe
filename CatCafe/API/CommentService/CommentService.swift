//
//  CommentService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import Firebase

struct CommentService {
    
    static func uploadComment(
        postId: String,
        user: User,
        commentType: Int,
        mediaUrlString: String,
        comment: String,
        completion: @escaping(FirestoreCompletion)
    ) {
        let dic: [String: Any] = [
            "uid": user.uid,
            "mediaType": commentType,
            "mediaUrlString": mediaUrlString,
            "comment": comment,
            "timestamp": Timestamp(date: Date())
        ]
        CCConstant.COLLECTION_POSTS
            .document(postId)
            .collection("comments")
            .addDocument(data: dic, completion: completion)
        
    }
    
    static func fetchComments() {
        
    }
}
