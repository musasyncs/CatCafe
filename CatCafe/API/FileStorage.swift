//
//  ImageUplader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Foundation
import FirebaseStorage
import ProgressHUD

struct FileStorage {
    
    enum ImageCategory: String {
        case profile
        case post
        case meet
    }
    
    static func uploadImage(for category: ImageCategory,
                            image: UIImage,
                            uid: String,
                            completion: @escaping(String) -> Void
    ) {
        let directory = "\(category.rawValue)/" + "_\(uid)" + ".jpg"
        let ref = Storage.storage().reference(withPath: directory)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        var task: StorageUploadTask!
        task = ref.putData(imageData, metadata: nil) { _, error in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
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
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    static func downloadImage(imageUrl: String,
                              completion: @escaping (_ image: UIImage?) -> Void
    ) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            // get it locally
//            print("We have local image")
            
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                print("couldnt convert local image")
                completion(UIImage(named: "avatar"))
            }
            
        } else {
            // download from Firebase
            
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil {
                        // Save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    } else {
                        print("no document in database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Save Locally
    static func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
}

// Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
