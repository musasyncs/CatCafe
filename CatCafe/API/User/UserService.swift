//
//  UserService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Firebase

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    
    static func createUserProfile(
        userId: String,
        profileImageUrlString: String,
        credentials: AuthCredentials,
        completion: @escaping(FirestoreCompletion)
    ) {
        let dic: [String: Any] = [
            "email": credentials.email,
            "fullname": credentials.fullname,
            "profileImageUrlString": profileImageUrlString,
            "uid": userId,
            "username": credentials.username
        ]
        
        CCConstant.COLLECTION_USERS.document(userId).setData(dic, completion: completion)
    }
    
    // MARK: - Fetch user by uid / Fetch users with uids / Fetch all users
    
    static func fetchUserBy(uid: String, completion: @escaping(User) -> Void) {
        CCConstant.COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            guard let dic = snapshot?.data() else { return }
            let user = User(dic: dic)
            completion(user)
        }
    }
    
    static func fetchUsersBy(withIds uids: [String], completion: @escaping([User]) -> Void) {
        
        var count = 0
        var userArray: [User] = []
        
        for uid in uids {
            CCConstant.COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
                guard let dic = snapshot?.data() else { return }
                let user = User(dic: dic)
                
                userArray.append(user)
                count += 1
                
                if count == uids.count {
                    completion(userArray)
                }
            }
        }
        
        
    }
    
    
    static func fetchUsers(exceptCurrentUser: Bool, completion: @escaping([User]) -> Void) {
        CCConstant.COLLECTION_USERS.limit(to: 500).getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            
            var users: [User] = []
            
            let allUsers = snapshot.documents.map({
                User(dic: $0.data())
            })
            
            for user in allUsers {
                if exceptCurrentUser {
                    if user.uid != LocalStorage.shared.getUid() {
                        users.append(user)
                    }
                } else {
                    users.append(user)
                }
            }
            
            completion(users)
        }
    }
    
    // MARK: - Follow / Unfollow User / Check if a user is followed
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_FOLLOWING
            .document(currentUid)
            .collection("user-following")
            .document(uid)
            .setData([:]
            ) { _ in
                CCConstant.COLLECTION_FOLLOWERS
                    .document(uid)
                    .collection("user-followers")
                    .document(currentUid)
                    .setData([:], completion: completion)
            }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_FOLLOWING
            .document(currentUid)
            .collection("user-following")
            .document(uid)
            .delete { _ in
                CCConstant.COLLECTION_FOLLOWERS
                    .document(uid)
                    .collection("user-followers")
                    .document(currentUid)
                    .delete(completion: completion)
            }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_FOLLOWING
            .document(currentUid)
            .collection("user-following")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let isFollowed = snapshot?.exists else { return }
                completion(isFollowed)
            }
    }
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        CCConstant.COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            let followers = snapshot?.documents.count ?? 0
            
            CCConstant.COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
                let following = snapshot?.documents.count ?? 0
                
                CCConstant.COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
                    .getDocuments { snapshot, _ in
                        let posts = snapshot?.documents.count ?? 0
                        completion(UserStats(followers: followers, following: following, postCounts: posts))
                    }
            }
        }
    }

}
