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
        guard let uid = LocalStorage.shared.getUid() else { return }
        
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
            let docRef = CCConstant.COLLECTION_POSTS.addDocument(data: dic, completion: completion)
            self.updateFeedAfterPost(postId: docRef.documentID)
        }
    }
    
    // MARK: - Fetch all posts / Fetch posts by uid / Fetch post with post id / Fetch feed posts
    
    static func fetchPosts(completion: @escaping(([Post]) -> Void)) {
        CCConstant.COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map { Post(postId: $0.documentID, dic: $0.data()) }
            completion(posts)
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping(([Post]) -> Void)) {
        let query = CCConstant.COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            var posts = documents.map { Post(postId: $0.documentID, dic: $0.data()) }
            posts.sort(by: {$0.timestamp.seconds > $1.timestamp.seconds })
            completion(posts)
        }
    }
    
    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void) {
        CCConstant.COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let dic = snapshot.data() else { return }
            let post = Post(postId: snapshot.documentID, dic: dic)
            completion(post)
        }
    }
    
    static func fetchFeedPosts(completion: @escaping([Post]) -> Void) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, _ in
            
            var posts = [Post]()
            snapshot?.documents.forEach({ document in
                fetchPost(withPostId: document.documentID) { post in
                    posts.append(post)
                    posts.sort(by: {$0.timestamp.seconds > $1.timestamp.seconds })
                    completion(posts)
                }
            })
            
            completion([Post]())
        }
    }
    
    // MARK: - Like a post / UnLike a post / Check if a user like a post
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
        
        CCConstant.COLLECTION_POSTS.document(post.postId)
            .collection("post-likes").document(uid).setData([:]) { _ in
                CCConstant.COLLECTION_USERS.document(uid)
                    .collection("user-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        guard post.likes > 0 else { return }
        
        CCConstant.COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
        
        CCConstant.COLLECTION_POSTS.document(post.postId)
            .collection("post-likes").document(uid).delete { _ in
                CCConstant.COLLECTION_USERS.document(uid)
                    .collection("user-likes").document(post.postId).delete(completion: completion)
            }
    }
    
    static func checkIfCurrentUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_USERS.document(uid)
            .collection("user-likes").document(post.postId).getDocument { snapshot, _ in
                guard let isLiked = snapshot?.exists else { return }
                completion(isLiked)
            }
    }
    
    // MARK: - Update feed after following or unfollowing / Update followers's feed after current user post
    
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        let query = CCConstant.COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let docIds = documents.map({ $0.documentID })
            
            docIds.forEach { id in
                if didFollow {
                    CCConstant.COLLECTION_USERS.document(uid).collection("user-feed").document(id).setData([:])
                } else {
                    CCConstant.COLLECTION_USERS.document(uid).collection("user-feed").document(id).delete()
                }
            }
            
        }
    }
    
    private static func updateFeedAfterPost(postId: String) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_FOLLOWERS.document(uid)
            .collection("user-followers").getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                
                // 給追蹤者
                documents.forEach { snapshot in
                    CCConstant.COLLECTION_USERS.document(snapshot.documentID)
                        .collection("user-feed").document(postId).setData([:])
                }
                
                // 給自己
                CCConstant.COLLECTION_USERS.document(uid).collection("user-feed").document(postId).setData([:])
            }
    }
    
}
