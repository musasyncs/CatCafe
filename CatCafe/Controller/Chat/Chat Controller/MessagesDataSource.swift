//
//  MessagesDatasource.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/6.
//

import MessageKit
import UIKit

extension ChatController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section % 3 == 0 {
            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount)
            
            let text = showLoadMore
            ? ""
            : MessageKitDateFormatter.shared.string(from: message.sentDate)
           
            let font = showLoadMore
            ? UIFont.systemFont(ofSize: 13, weight: .regular)
            : UIFont.systemFont(ofSize: 13, weight: .regular)
           
            let color = showLoadMore ? UIColor.darkGray : UIColor.ccGreyVariant
            
            return NSAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: color
                ]
            )
        }
        return nil
    }
    
    // Read / sent status and date label
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readDate.time() : ""
            
            return NSAttributedString(
                string: status,
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.ccGrey
                ]
            )
        }
        return nil
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section != mkMessages.count - 1 {
            return NSAttributedString(
                string: message.sentDate.time(),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.ccGrey
                ]
            )
        }
        return nil
    }
}
