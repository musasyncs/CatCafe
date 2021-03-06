//
//  Notification.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import FirebaseFirestore

enum NotitficationType: Int {
    case like
    case follow
    case comment
    
    var notificationMessage: String {
        switch self {
        case .like: return " 說你的貼文讚。"
        case .follow: return " 開始追蹤你。"
        case .comment: return " 在你的貼文上留言。"
        }
    }
}

struct Notification {
    let notiId: String
    let notiType: NotitficationType
    let fromUid: String
    let postId: String
    let timestamp: Timestamp
    
    var userIsFollowed = false
    
    init(dic: [String: Any]) {
        self.notiId     = dic["notiId"] as? String ?? ""
        self.notiType   = NotitficationType(rawValue: dic["notiType"] as? Int ?? 0) ?? .like
        self.fromUid    = dic["fromUid"] as? String ?? ""
        self.postId     = dic["postId"] as? String ?? ""
        self.timestamp  = dic["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
    }
}
