//
//  UserService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Firebase

struct UserService {
    
    static func fetchCurrentUser(completion: @escaping(User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        CCConstant.COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
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
        
}
