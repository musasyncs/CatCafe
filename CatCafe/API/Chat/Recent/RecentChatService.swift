//
//  RecentChatService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/28.
//

import Foundation
import Firebase

class RecentChatService {
    
    static let shared = RecentChatService()
    
    private init() {}
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.recent)
            .whereField(CCConstant.SENDERID, isEqualTo: currentUid)
            .addSnapshotListener { (snapshot, _) in
            
            var recentChats: [RecentChat] = []
            
            guard let documents = snapshot?.documents else {
                print("no documents for recent chats")
                return
            }
            
            let allRecents = documents.compactMap { (snapshot) -> RecentChat? in
                return try? snapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecents {
                if !recent.lastMessage.isEmpty {
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
        }
    }
    
    func resetRecentCounter(chatRoomId: String) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.recent)
            .whereField(CCConstant.CHATROOMID, isEqualTo: chatRoomId)
            .whereField(CCConstant.SENDERID, isEqualTo: currentUid)
            .getDocuments { (snapshot, _) in
            
            guard let documents = snapshot?.documents else {
                print("no documents for recent")
                return
            }
            
            let allRecents = documents.compactMap { (snapshot) -> RecentChat? in
                return try? snapshot.data(as: RecentChat.self)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        firebaseReference(.recent)
            .whereField(CCConstant.CHATROOMID, isEqualTo: chatRoomId)
            .getDocuments { (querySnapshot, _) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        var tempRecent = recent
        
        if tempRecent.receiverId == LocalStorage.shared.getUid() {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
    }
    
    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent)
    }
    
    func saveRecent(_ recent: RecentChat) {
        do {
            try firebaseReference(.recent).document(recent.id).setData(from: recent)
        } catch {
            print("Error saving recent chat ", error.localizedDescription)
        }
    }
    
    func deleteRecent(_ recent: RecentChat) {
        firebaseReference(.recent).document(recent.id).delete()
    }
    
}
