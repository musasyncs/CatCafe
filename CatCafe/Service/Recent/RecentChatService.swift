//
//  RecentChatService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/28.
//

import FirebaseFirestore

class RecentChatService {
    
    static let shared = RecentChatService()
    private init() {}
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.recent)
            .whereField(CCConstant.SENDERID, isEqualTo: currentUid)
            .addSnapshotListener { snapshot, error in
                
                if error != nil { return }
                var recentChats: [RecentChat] = []
                
                guard let documents = snapshot?.documents else { return }
                
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
        
    func updateRecents(chatRoomId: String, lastMessage: String) {
        firebaseReference(.recent)
            .whereField(CCConstant.CHATROOMID, isEqualTo: chatRoomId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if error != nil { return }
                guard let documents = snapshot?.documents else { return }
                
                let allRecents = documents.compactMap { snapshot -> RecentChat? in
                    return try? snapshot.data(as: RecentChat.self)
                }
                
                for recentChat in allRecents {
                    self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
                }
            }
    }
    
    func resetRecentCounter(chatRoomId: String) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.recent)
            .whereField(CCConstant.CHATROOMID, isEqualTo: chatRoomId)
            .whereField(CCConstant.SENDERID, isEqualTo: currentUid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if error != nil { return }
                
                guard let documents = snapshot?.documents else { return }
                
                let allRecents = documents.compactMap { snapshot -> RecentChat? in
                    return try? snapshot.data(as: RecentChat.self)
                }
                
                if allRecents.count > 0 {
                    self.clearUnreadCounter(recent: allRecents.first!)
                }
            }
    }
    
    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent)
    }
    
    func deleteRecent(_ recent: RecentChat) {
        firebaseReference(.recent).document(recent.id).delete()
    }
    
    func saveRecent(_ recent: RecentChat) {
        do {
            try firebaseReference(.recent).document(recent.id).setData(from: recent)
        } catch {
            print("Error saving recent chat ", error.localizedDescription)
        }
    }
    
    // Private function
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        var recent = recent
        
        if recent.receiverId == LocalStorage.shared.getUid() {
            recent.unreadCounter += 1
        }
        
        recent.lastMessage = lastMessage
        recent.date = Date()
        
        self.saveRecent(recent)
    }

}
