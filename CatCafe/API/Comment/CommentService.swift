//
//  CommentService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import Firebase

struct CommentService {
    
    // MARK: - Upload comment for a post
    
    // swiftlint:disable:next function_parameter_count
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
    
    // MARK: - Fetch all comments for a post
    
    static func fetchComments(
        forPost postId: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        var comments = [Comment]()
        
        let query = CCConstant.COLLECTION_POSTS.document(postId).collection("comments")
            .order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, _ in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    let comment = Comment(dic: data)
                    comments.append(comment)
                }
            })
            
            completion(comments)
        }
    }
    
    // MARK: - Upload comment for a meet
    
    // swiftlint:disable:next function_parameter_count
    static func uploadMeetComment(
        meetId: String,
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
        CCConstant.COLLECTION_MEETS
            .document(meetId)
            .collection("comments")
            .addDocument(data: dic, completion: completion)
        
    }
    
    // MARK: - Fetch all comments for a meet
    
    static func fetchMeetComments(
        forMeet meetId: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        var comments = [Comment]()
        
        let query = CCConstant.COLLECTION_MEETS
            .document(meetId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, _ in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    let comment = Comment(dic: data)
                    comments.append(comment)
                }
            })
            
            completion(comments)
        }
    }
    
}
