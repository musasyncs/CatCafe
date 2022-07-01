//
//  InputBarAccessoryViewDelegate.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import Foundation
import InputBarAccessoryView

extension ChatController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != "" {
            typingIndicatorUpdate()
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text, photo: nil, video: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
}
