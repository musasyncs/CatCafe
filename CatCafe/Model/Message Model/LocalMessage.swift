//
//  LocalMessage.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import Foundation

class LocalMessage: Codable {
    var id = ""
    var chatRoomId = ""
    var date = Date()
    
    var senderName = ""
    var senderId = ""
    var senderinitials = ""
    
    var type = ""
    var status = ""
    var readDate = Date()
    
    var message = ""
    var videoUrl = ""
    var pictureUrl = ""
}
