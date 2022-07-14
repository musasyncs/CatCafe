//
//  CommentService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import FirebaseFirestore

class CommentService {
    
    static let shared = CommentService()
    private init() {}
    
    // MARK: - Upload comment for a post
    // swiftlint:disable:next function_parameter_count
    func uploadComment(
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
        firebaseReference(.posts)
            .document(postId)
            .collection("comments")
            .addDocument(data: dic, completion: completion)
        
    }
    
    // MARK: - Fetch all comments for a post
    func fetchComments(
        forPost postId: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        var comments = [Comment]()
        let group = DispatchGroup()
        
        let query = firebaseReference(.posts).document(postId).collection("comments")
            .order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, _ in
            
            snapshot?.documentChanges.forEach({ change in
                
                if change.type == .added {
                    let dic = change.document.data()
                    
                    guard let commentUid = dic["uid"] as? String else {
                        completion([Comment]())
                        return
                    }
                    
                    group.enter()
                    UserService.shared.fetchUserBy(uid: commentUid) { user in
                        let comment = Comment(user: user, dic: dic)
                        comments.append(comment)
                        group.leave()
                    }
                    
                }
            })
            
            group.notify(queue: DispatchQueue.main) {
                completion(comments)
            }
        }
    }
    
    // MARK: - Upload comment for a meet
    // swiftlint:disable:next function_parameter_count
    func uploadMeetComment(
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
        firebaseReference(.meets)
            .document(meetId)
            .collection("comments")
            .addDocument(data: dic, completion: completion)
        
    }
    
    // MARK: - Fetch all comments for a meet
    func fetchMeetComments(
        forMeet meetId: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        var comments = [Comment]()
        let group = DispatchGroup()
        
        let query = firebaseReference(.meets)
            .document(meetId)
            .collection("comments")
            .order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, _ in
            
            snapshot?.documentChanges.forEach({ change in
                
                if change.type == .added {
                    let dic = change.document.data()
                    
                    guard let commentUid = dic["uid"] as? String else {
                        completion([Comment]())
                        return
                    }
                    
                    group.enter()
                    UserService.shared.fetchUserBy(uid: commentUid) { user in
                        let comment = Comment(user: user, dic: dic)
                        comments.append(comment)
                        group.leave()
                    }
                    
                }
            })
            
            group.notify(queue: DispatchQueue.main) {
                completion(comments)
            }
            
        }
    }
    
}
