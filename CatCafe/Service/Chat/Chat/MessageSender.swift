//
//  MessageSender.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import UIKit
import FirebaseFirestoreSwift
import Gallery
import AVFoundation

class MessageSender {
    
    // swiftlint:disable:next function_parameter_count
    class func send(chatId: String,
                    text: String?,
                    photo: UIImage?,
                    video: Video?,
                    memberIds: [String],
                    completion: @escaping((LocalMessage) -> Void)
    ) {
        let currentUser = UserService.shared.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.uid
        message.senderName = currentUser.username
        message.senderinitials = String(currentUser.username.first ?? "\u{7E}")
        
        message.date = Date()
        message.status = CCConstant.SENT
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: memberIds, completion: completion)
        }
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds, completion: completion)
        }
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds, completion: completion)
        }
        
        RecentChatService.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
    }
    
    // 這時才拿到完整的 message 資訊
    class func sendMessage(message: LocalMessage, memberIds: [String], completion: @escaping ((LocalMessage) -> Void)) {
        completion(message)
        
        for memberId in memberIds {
            MessageService.shared.addMessage(message, memberId: memberId)
        }
    }
    
}

private func sendTextMessage(
    message: LocalMessage,
    text: String,
    memberIds: [String],
    completion: @escaping ((LocalMessage) -> Void)
) {
    message.message = text
    message.type = CCConstant.TEXT
    MessageSender.sendMessage(message: message, memberIds: memberIds, completion: completion)
}

private func sendPictureMessage(
    message: LocalMessage,
    photo: UIImage,
    memberIds: [String],
    completion: @escaping ((LocalMessage) -> Void)
) {
    message.message = "Picture Message"
    message.type = CCConstant.PHOTO
    
    let fileName = Date().stringDate()
    let directory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(photo, directory: directory) { imageUrlString in
        message.pictureUrl = imageUrlString
        MessageSender.sendMessage(message: message, memberIds: memberIds, completion: completion)
    }
}

private func sendVideoMessage(
    message: LocalMessage,
    video: Video,
    memberIds: [String],
    completion: @escaping ((LocalMessage) -> Void)
) {
    message.message = "Video Message"
    message.type = CCConstant.VIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    
    editor.process(video: video) { (_, videoUrl) in
        if let tempPath = videoUrl {
            let thubnail = videoThumbnail(video: tempPath)
            
            FileStorage.saveFileLocally(
                fileData: thubnail.jpegData(compressionQuality: 0.7)! as NSData,
                fileName: fileName
            )
            
            FileStorage.uploadImage(thubnail, directory: thumbnailDirectory) { (imageLink) in
                let videoData = NSData(contentsOfFile: tempPath.path)
                
                FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                
                FileStorage.uploadVideo(videoData!, directory: videoDirectory) { (videoLink) in
                    message.pictureUrl = imageLink
                    message.videoUrl = videoLink ?? ""
                    MessageSender.sendMessage(message: message, memberIds: memberIds, completion: completion)
                }
                
            }
        }
    }
}

private func videoThumbnail(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch let error as NSError {
        print("error making thumbnail ", error.localizedDescription)
    }
    
    if image != nil {
        return UIImage(cgImage: image!)
    } else {
        return UIImage.asset(.photoPlaceholder)!
    }
}
