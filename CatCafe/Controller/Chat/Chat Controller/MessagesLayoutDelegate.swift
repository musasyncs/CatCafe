//
//  MessageDisplayDelegate.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import Foundation
import MessageKit

extension ChatController: MessagesLayoutDelegate {
    
    private enum MessageDefaults {
        static let bubbleColorOutgoing = UIColor.systemBrown.withAlphaComponent(0.6)
        static let bubbleColorIncoming = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
    }
    
    func textColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        return .label
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
