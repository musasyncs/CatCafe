//
//  CCConstant.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import Firebase

// swiftlint:disable identifier_name
struct CCConstant {
    
    struct LocalStorageKey {
        static let userIdKey = "userIdKey"
        static let hasLogedIn = "hasLogedIn"
        static let currentUser = "currentUser"
    }
    
    struct NotificationName {
        static let updateFeed = NSNotification.Name("updateFeed")
        static let updateMeetFeed = NSNotification.Name("updateMeetFeed")
    }

    static let NUMBEROFMESSAGES = 12

    static let STATUS = "status"
    static let FIRSTRUN = "firstRUN"

    static let CHATROOMID = "chatRoomId"
    static let SENDERID = "senderId"

    static let SENT = "Sent"
    static let READ = "Read"

    static let TEXT = "text"
    static let PHOTO = "photo"
    static let VIDEO = "video"
    static let AUDIO = "audio"
    static let LOCATION = "location"

    static let DATE = "date"
    static let READDATE = "date"

    static let ADMINID = "adminId"
    static let MEMBERIDS = "memberIds"
}
// swiftlint:enable identifier_name
