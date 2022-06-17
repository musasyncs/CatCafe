//
//  ImageUplader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import FirebaseStorage

struct ImageUplader {
    
    static func uploadProfileImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to fetch downloadUrl: \(error.localizedDescription)")
                    return
                }
                guard let imageUrlString = url?.absoluteString else { return }
                print("DEBUG: Successfully uploaded profile image:", imageUrlString)
                completion(imageUrlString)
            }
        }
    }
    
    static func uploadPostImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.95) else { return }
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/post_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to fetch downloadUrl: \(error.localizedDescription)")
                    return
                }
                guard let imageUrlString = url?.absoluteString else { return }
                print("DEBUG: Successfully uploaded post image:", imageUrlString)
                completion(imageUrlString)
            }
        }
    }
}
