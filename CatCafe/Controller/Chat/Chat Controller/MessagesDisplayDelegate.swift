//
//  MessageLayoutDelegate.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import MessageKit
import UIKit

extension ChatController: MessagesDisplayDelegate {
    
    func cellTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 50
        } else {
            return 0
        }
    }
    
    func cellBottomLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        return isFromCurrentSender(message: message) ? 20 : 0
    }
    
    func messageBottomLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 20 : 0
    }
    
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
        
        avatarView.backgroundColor = .ccGreyVariant
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.layer.borderWidth = 2
    }
}
