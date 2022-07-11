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
    
    // MARK: - Upload and download Image
    static func uploadImage(_ image: UIImage,
                            directory: String,
                            completion: @escaping (String) -> Void
    ) {
        let ref = Storage.storage().reference(withPath: directory)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return
        }
        
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
    
    static func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            // get it locally
//            print("We have local image")
            
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                print("couldnt convert local image")
                completion(UIImage.asset(.avatar))
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
    
    // MARK: - Upload and download Video
    static func uploadVideo(_ video: NSData,
                            directory: String,
                            completion: @escaping (_ videoLink: String?) -> Void
    ) {
        let ref = Storage.storage().reference(withPath: directory)
        var task: StorageUploadTask!
        
        task = ref.putData(video as Data, metadata: nil, completion: { (_, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
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
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }

    static func downloadVideo(
        videoLink: String,
        completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void
    ) {
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"

        if fileExistsAtPath(path: videoFileName) {
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
    
    // MARK: - Upload and dowload Audio
    static func uploadAudio(_ audioFileName: String,
                            directory: String,
                            completion: @escaping (_ audioLink: String?) -> Void
    ) {
        let fileName = audioFileName + ".m4a"
        let ref = Storage.storage().reference(withPath: directory)
                        
        var task: StorageUploadTask!
        
        if fileExistsAtPath(path: fileName) {
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                
                task = ref.putData(audioData as Data, metadata: nil, completion: { (_, error) in
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("error uploading audio \(error!.localizedDescription)")
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
                
                task.observe(StorageTaskStatus.progress) { (snapshot) in
                    
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(progress))
                }
            } else {
                print("nothing to upload (audio)")
            }
        }
    }

    static func downloadAudio(audioLink: String, completion: @escaping (_ audioFileName: String) -> Void) {
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"

        if fileExistsAtPath(path: audioFileName) {
            completion(audioFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            
            downloadQueue.async {
                let data = NSData(contentsOf: URL(string: audioLink)!)
                if data != nil {
                    // Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)
                    
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                } else {
                    print("no document in database audio")
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
