//
//  UserService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Firebase
import CoreMedia

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    
    static func fetchCurrentUser(completion: @escaping(User) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        CCConstant.COLLECTION_USERS.document(currentUid).getDocument { snapshot, _ in
            guard let dic = snapshot?.data() else { return }
            let user = User(dic: dic)
            completion(user)
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        
        CCConstant.COLLECTION_USERS.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            let users = snapshot.documents.map({
                User(dic: $0.data())
            })
            
            completion(users)
        }
    }
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
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
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        CCConstant.COLLECTION_FOLLOWING
            .document(currentUid)
            .collection("user-following")
            .document(uid)
            .delete { error in
                CCConstant.COLLECTION_FOLLOWERS
                    .document(uid)
                    .collection("user-followers")
                    .document(currentUid)
                    .delete(completion: completion)
            }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        CCConstant.COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, _ in
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
}
