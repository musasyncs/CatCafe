//
//  ImageUplader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import FirebaseStorage

struct ImageUplader {
    
    enum ImageCategory: String {
        case profile
        case post
        case meet
    }
    
    static func uploadImage(for category: ImageCategory, image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage().reference(withPath: "/\(category.rawValue)_images/\(filename)")
        
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
                print("DEBUG: Successfully uploaded image:", imageUrlString)
                completion(imageUrlString)
            }
        }
    }
}
