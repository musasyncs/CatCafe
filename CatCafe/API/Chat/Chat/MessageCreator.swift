//
//  MessageReceiver.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import MessageKit

class MessageCreator {
    
    var messageCollectionView: MessagesViewController
    
    // swiftlint:disable identifier_name
    init(_collectionView: MessagesViewController) {
        messageCollectionView = _collectionView
    }
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        
        // message type is photo
        if localMessage.type == CCConstant.PHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (image) in
                mkMessage.photoItem?.image = image
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        // message type is video
        if localMessage.type == CCConstant.VIDEO {
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (thumbNail) in
                
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { (_, fileName) in
                    let videoURL = URL(fileURLWithPath: filePathInDocumentsDirectory(fileName: fileName))
                    let videoItem = VideoMessage(url: videoURL)
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                
                mkMessage.videoItem?.image = thumbNail
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        return mkMessage
    }
    
}
