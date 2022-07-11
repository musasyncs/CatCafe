//
//  MessageDisplayDelegate.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import MessageKit

extension ChatController: MessagesLayoutDelegate {
    
    private enum MessageDefaults {
        static let bubbleColorOutgoing = UIColor.ccPrimary
        static let bubbleColorIncoming = UIColor.ccGreyVariant.withAlphaComponent(0.1)
    }
    
    func textColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        return isFromCurrentSender(message: message)
        ? .white
        : .ccGrey
    }
    
    func backgroundColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        return isFromCurrentSender(message: message)
        ? MessageDefaults.bubbleColorOutgoing
        : MessageDefaults.bubbleColorIncoming
    }
    
    func messageStyle(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
}
