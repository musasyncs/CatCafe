//
//  UserService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Firebase

typealias FirestoreCompletion = (Error?) -> Void

class UserService {
    
    static let shared = UserService()
    
    private init() {}
    
    var currentUser: User?
    
    // MARK: - Create user profile / Upload profile image
    
    // 創建個人檔案
    func createUserProfile(
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
        
        firebaseReference(.users)
            .document(userId)
            .setData(dic, completion: completion)
    }
        
    // 個人檔案資料更新 (除了頭貼 urlString )
    func updateCurrentUserInfo(
        fullname: String,
        username: String,
        email: String,
        completion: @escaping(FirestoreCompletion)
    ) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        let dic: [String: Any] = [
            "email": email,
            "fullname": fullname,
            "uid": currentUid,
            "username": username
        ]
        
        firebaseReference(.users)
            .document(currentUid)
            .updateData(dic, completion: completion)
    }
    
    // 個人檔案頭貼 urlString 更新
    func uploadProfileImage(
        userId: String,
        profileImageUrlString: String,
        completion: @escaping(FirestoreCompletion)
    ) {
        firebaseReference(.users)
            .document(userId)
            .updateData(["profileImageUrlString": profileImageUrlString], completion: completion)
    }
    
    // MARK: - FetchCurrentUser / Fetch user by uid / Fetch users with uids / Fetch all users
    func fetchCurrentUser(completion: @escaping(User) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        firebaseReference(.users).document(currentUid).getDocument { snapshot, _ in
            guard let dic = snapshot?.data() else { return }
            let currentUser = User(dic: dic)
            self.currentUser = currentUser
            completion(currentUser)
        }
    }
    
    func fetchUserBy(uid: String, completion: @escaping(User) -> Void) {
        firebaseReference(.users).document(uid).getDocument { snapshot, _ in
            guard let dic = snapshot?.data() else { return }
            let user = User(dic: dic)
            completion(user)
        }
    }
    
    func fetchUsersBy(withIds uids: [String], completion: @escaping([User]) -> Void) {
        var count = 0
        var userArray: [User] = []
        
        for uid in uids {
            firebaseReference(.users).document(uid).getDocument { snapshot, _ in
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
        firebaseReference(.users).limit(to: 500).getDocuments { snapshot, _ in
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
        
        firebaseReference(.following)
            .document(currentUid)
            .collection("user-following")
            .document(uid)
            .setData([:]
            ) { _ in
                firebaseReference(.followers)
                    .document(uid)
                    .collection("user-followers")
                    .document(currentUid)
                    .setData([:], completion: completion)
            }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.following)
            .document(currentUid)
            .collection("user-following")
            .document(uid)
            .delete { _ in
                firebaseReference(.followers)
                    .document(uid)
                    .collection("user-followers")
                    .document(currentUid)
                    .delete(completion: completion)
            }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.following)
            .document(currentUid)
            .collection("user-following")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let isFollowed = snapshot?.exists else { return }
                completion(isFollowed)
            }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        firebaseReference(.followers).document(uid).collection("user-followers").getDocuments { snapshot, _ in
            let followers = snapshot?.documents.count ?? 0
            
            firebaseReference(.following).document(uid).collection("user-following").getDocuments { snapshot, _ in
                let following = snapshot?.documents.count ?? 0
                
                firebaseReference(.posts).whereField("ownerUid", isEqualTo: uid)
                    .getDocuments { snapshot, _ in
                        let posts = snapshot?.documents.count ?? 0
                        completion(UserStats(followers: followers, following: following, postCounts: posts))
                    }
            }
        }
    }
    
}
