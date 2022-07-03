//
//  MKMessage.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import Foundation
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

class MKMessage: NSObject, MessageType {
    var messageId: String
    var kind: MessageKind
    var sender: SenderType {
        return mkSender
    }
    var mkSender: MKSender
    var senderInitials: String
    
    var sentDate: Date
    var readDate: Date
    
    var incoming: Bool
    var status: String
    
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.kind = MessageKind.text(message.message)
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        
        switch message.type {
        case CCConstant.TEXT:
            self.kind = MessageKind.text(message.message)

        case CCConstant.PHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case CCConstant.VIDEO:
            let videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem

        default:
            self.kind = MessageKind.text(message.message)
            print("unknown message type")
        }
        
        self.senderInitials = message.senderinitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = LocalStorage.shared.getUid()! != mkSender.senderId
    }
}
