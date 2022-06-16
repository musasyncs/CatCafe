//
//  AuthService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct AuthService {
    
//    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
//        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
//    }
    
    static func logUserIn(withEmail email: String,
                          password: String,
                          completion: @escaping(AuthDataResult?, Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredial credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        ImageUplader.uploadImage(image: credentials.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                if let error = error {
                    print("DEBUG: Failed to register user \(error.localizedDescription)")
                    return
                }
                guard let uid = result?.user.uid else { return }
                let dic: [String: Any] = ["email": credentials.email,
                                          "fullname": credentials.fullname,
                                          "profileImageUrl": imageUrl,
                                          "uid": uid,
                                          "username": credentials.username]
                
                CCConstant.COLLECTION_USERS.document(uid).setData(dic, completion: completion)
            }
        }
    }
}
