//
//  NotificationService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import Firebase

struct NotificationService {
    
    static func uploadNotification(
        toUid uid: String,
        notiType: NotitficationType,
        post: Post? = nil
    ) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return } // 不要通知自己東西
        
        let docRef = CCConstant.COLLECTION_NOTIFICATIONS.document(uid)
            .collection("user-notifications").document()
        
        var dic: [String: Any] = [
            "notiId": docRef.documentID,
            "timestamp": Timestamp(date: Date()),
            "uid": currentUid,
            "notiType": notiType.rawValue
        ]
        
        if let post = post {
            dic["postId"] = post.postId
        }
        
        docRef.setData(dic)
    }
    
    static func fetchNotifications() {
        
    }
}
