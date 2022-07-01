//
//  TypingListener.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import Foundation
import Firebase

class TypingService {
    
    static let shared = TypingService()
    var typingListener: ListenerRegistration!
    
    private init() { }
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        
        typingListener = firebaseReference(.typing)
            .document(chatRoomId)
            .addSnapshotListener({ (snapshot, _) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                // swiftlint:disable force_cast
                for data in snapshot.data()! {
                    if data.key != LocalStorage.shared.getUid()! {
                        completion(data.value as! Bool)
                    }
                }
                // swiftlint:enable force_cast
            } else {
                completion(false)
                firebaseReference(.typing).document(chatRoomId).setData([LocalStorage.shared.getUid()!: false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        firebaseReference(.typing).document(chatRoomId).updateData([LocalStorage.shared.getUid()!: typing])

    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
    
}
