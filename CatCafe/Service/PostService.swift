//
//  PostService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import UIKit
import FirebaseFirestore

class PostService {
    
    static let shared = PostService()
    private init() {}
    
    // MARK: - Upload image post
    func uploadImagePost(caption: String,
                         postImage: UIImage,
                         cafeId: String,
                         cafeName: String,
                         completion: @escaping (FirestoreCompletion)
    ) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        let fileName = Date().stringDate()
        let directory = "Post/" + "_\(uid)" + "_\(fileName)" + ".jpg"
        
        FileStorage.uploadImage(postImage, directory: directory) { imageUrlString in
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
            let docRef = firebaseReference(.posts).addDocument(data: dic, completion: completion)
            PostService.shared.updateFeedAfterPost(postId: docRef.documentID)
        }
    }
    
    // MARK: - Fetch all posts / Fetch feed posts / Fetch posts by uid / Fetch post with post id
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        firebaseReference(.posts).getDocuments { snapshot, _ in
            var posts = [Post]()
            let group = DispatchGroup()
            
            snapshot?.documents.forEach({ snapshot in
                
                let postId = snapshot.documentID
                let dic = snapshot.data()
                guard let uid = dic["ownerUid"] as? String else { return }
                
                group.enter()
                UserService.shared.fetchUserBy(uid: uid) { user in
                    let post = Post(user: user, postId: postId, dic: dic)
                    posts.append(post)
                    group.leave()
                }
            })
            
            group.notify(queue: DispatchQueue.main) {
                posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                completion(.success(posts))
            }
            
        }
    }
    
    func fetchFeedPosts(completion: @escaping ([Post]) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.users).document(currentUid).collection("user-feed").getDocuments { snapshot, _ in
            var posts = [Post]()
            let group = DispatchGroup()
            
            snapshot?.documents.forEach({ [weak self] snapshot in
                guard let self = self else { return }
                
                group.enter()
                self.fetchPost(withPostId: snapshot.documentID) { result in
                    switch result {
                    case .success(let post):
                        posts.append(post)
                        group.leave()
                    case .failure:
                        completion([Post]())
                    }
                }
            })
            
            group.notify(queue: DispatchQueue.main) {
                posts.sort(by: {
                    $0.timestamp.seconds > $1.timestamp.seconds
                })
                completion(posts)
            }
            
        }
    }
    
    func fetchPosts(forUser uid: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        firebaseReference(.posts).whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, _ in
            
            var posts = [Post]()
            let group = DispatchGroup()
            
            snapshot?.documents.forEach({ snapshot in
                let postId = snapshot.documentID
                let dic = snapshot.data()
                guard let uid = dic["ownerUid"] as? String else { return }
                
                group.enter()
                UserService.shared.fetchUserBy(uid: uid) { user in
                    let post = Post(user: user, postId: postId, dic: dic)
                    posts.append(post)
                    group.leave()
                }
            })
            
            group.notify(queue: DispatchQueue.main) {
                posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                completion(.success(posts))
            }
        }
    }
    
    func fetchPost(withPostId postId: String, completion: @escaping (Result<Post, Error>) -> Void) {
        firebaseReference(.posts).document(postId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot,
                      let dic = snapshot.data(),
                      let uid = dic["ownerUid"] as? String else { return }
                UserService.shared.fetchUserBy(uid: uid) { user in
                    let post = Post(user: user, postId: snapshot.documentID, dic: dic)
                    completion(.success(post))
                }

            }
            
        }
    }
    
    // MARK: - Fetch Like Count / Like a post / UnLike a post / Check if current user like a post
    func fetchLikeCount(post: Post, completion: @escaping ((Int) -> Void)) {
        PostService.shared.fetchPost(withPostId: post.postId) { result in
            switch result {
            case .success(let post):
                completion(post.likes)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func likePost(post: Post, completion: @escaping (FirestoreCompletion)) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        PostService.shared.fetchLikeCount(post: post) { likeCount in
                    
            firebaseReference(.posts).document(post.postId).updateData(["likes": likeCount + 1]) { error in
                if error != nil { return }
                
                firebaseReference(.posts).document(post.postId)
                    .collection("post-likes").document(uid).setData([:]) { error in
                        if error != nil { return }
                        
                        firebaseReference(.users).document(uid)
                            .collection("user-post-likes").document(post.postId).setData([:], completion: completion)
                    }
            }

        }
                
    }
    
    func unlikePost(post: Post, completion: @escaping (FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        guard post.likes > 0 else { return }
        
        PostService.shared.fetchLikeCount(post: post) { likeCount in
        
            firebaseReference(.posts).document(post.postId).updateData(["likes": likeCount - 1]) { error in
                if error != nil { return }
                
                firebaseReference(.posts).document(post.postId)
                    .collection("post-likes").document(currentUid).delete { error in
                        if error != nil { return }
                        
                        firebaseReference(.users).document(currentUid)
                            .collection("user-post-likes").document(post.postId).delete(completion: completion)
                    }
            }
            
        }
        
    }
    
    func checkIfCurrentUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.users).document(uid)
            .collection("user-post-likes").document(post.postId).getDocument { snapshot, error in
                if error != nil { return }
                guard let isLiked = snapshot?.exists else { return }
                completion(isLiked)
            }
    }
    
    // MARK: - Update feed
    // After following or unfollowing
    // After current user post an article
    // After delete
    func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        let query = firebaseReference(.posts).whereField("ownerUid", isEqualTo: user.uid)
        query.getDocuments { snapshot, error in
            if error != nil { return }
            guard let documents = snapshot?.documents else { return }
            let docIds = documents.map({ $0.documentID })
            
            docIds.forEach { id in
                if didFollow {
                    firebaseReference(.users).document(uid).collection("user-feed").document(id).setData([:])
                } else {
                    firebaseReference(.users).document(uid).collection("user-feed").document(id).delete()
                }
            }
            
        }
    }
    
    private func updateFeedAfterPost(postId: String) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.followers).document(currentUid)
            .collection("user-followers").getDocuments { snapshot, error in
                if error != nil { return }
                guard let documents = snapshot?.documents else { return }
                
                // 給追蹤者
                documents.forEach { snapshot in
                    firebaseReference(.users).document(snapshot.documentID)
                        .collection("user-feed").document(postId).setData([:])
                }
                
                // 給自己
                firebaseReference(.users).document(currentUid).collection("user-feed").document(postId).setData([:])
            }
    }

}
