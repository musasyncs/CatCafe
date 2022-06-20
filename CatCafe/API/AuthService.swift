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
    
    enum AuthError: Error {
        case unknownError
    }
    
    static func registerUser(
        withCredial credentials: AuthCredentials,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {
        Auth.auth().createUser(
            withEmail: credentials.email,
            password: credentials.password
        ) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            } else if let authUser = authResult?.user {
                completion(.success(authUser))
            } else {
                completion(.failure(AuthError.unknownError))
            }
        }
    }
    
    static func loginUser(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {
        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authUser = authResult?.user {
                completion(.success(authUser))
            } else {
                completion(.failure(AuthError.unknownError))
            }
        }
    }
    
    static func logoutUser() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
