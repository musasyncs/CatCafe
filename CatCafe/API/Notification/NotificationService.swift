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
        fromUser: User,
        post: Post? = nil
    ) {
        guard fromUser.uid != uid else { return }
        
        let docRef = firebaseReference(.notifications)
            .document(uid)
            .collection("user-notifications").document()
        
        var dic: [String: Any] = [
            "notiId": docRef.documentID,
            "notiType": notiType.rawValue,
            "fromUid": fromUser.uid,
            "timestamp": Timestamp(date: Date())
        ]
        
        if let post = post {
            dic["postId"] = post.postId
        } else {
            dic["postId"] = ""
        }
        
        docRef.setData(dic)
    }
    
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        let query = firebaseReference(.notifications)
            .document(currentUid)
            .collection("user-notifications").order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, _ in
            guard let snapshots = snapshot?.documents else { return }
            let notifications = snapshots.map({ Notification(dic: $0.data()) })
            completion(notifications)
        }
    }
}
