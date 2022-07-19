//
//  ImageUplader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import FirebaseStorage
import ProgressHUD

struct FileStorage {
    
    // MARK: - Upload Image
    static func uploadImage(_ image: UIImage,
                            directory: String,
                            completion: @escaping (String) -> Void
    ) {
        let ref = Storage.storage().reference(withPath: directory)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        var task: StorageUploadTask!
        task = ref.putData(imageData, metadata: nil) { _, error in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil { return }
            ref.downloadURL { url, error in
                if error != nil { return }
                guard let imageUrlString = url?.absoluteString else { return }
                completion(imageUrlString)
            }
        }
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    // MARK: - Download Image
    static func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(filename: imageFileName) {
            // get it locally
            if let contentsOfFile = UIImage(contentsOfFile: filePathInDocumentsDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                print("couldnt convert local image")
                completion(UIImage.asset(.no_image))
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
    
    // MARK: - Upload Video
    static func uploadVideo(_ video: NSData,
                            directory: String,
                            completion: @escaping (_ videoLink: String?) -> Void
    ) {
        let ref = Storage.storage().reference(withPath: directory)
        ref.putData(video as Data, metadata: nil, completion: { (_, error) in
            
            if error != nil {
                print("error uploading video \(error!.localizedDescription)")
                return
            }
            
            ref.downloadURL { (url, _) in
                guard let downloadUrl = url  else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })

    }
    
    // MARK: - download Video
    static func downloadVideo(
        videoLink: String,
        completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void
    ) {
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        
        if fileExistsAtPath(filename: videoFileName) {
            completion(true, videoFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            
            downloadQueue.async {
                let data = NSData(contentsOf: videoUrl!)
                if data != nil {
                    // Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                    
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                } else {
                    print("no document in database")
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
func filePathInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(filename: String) -> Bool {
    return FileManager.default.fileExists(atPath: filePathInDocumentsDirectory(fileName: filename))
}
