//
//  AuthService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

class AuthService {
    
    static let shared = AuthService()
    private init() {}
    
    fileprivate var currentNonce: String?
    
    enum AuthError: Error {
        case unknownError
    }
    
    func registerUser(
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
    
    func loginUser(
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
    
    func logoutUser() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            UserService.shared.currentUser = nil
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Apple Sign-in
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization,
        completion: @escaping (AuthDataResult?) -> Void
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")
            print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    completion(nil)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                completion(authResult)
            }
        }
        
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
