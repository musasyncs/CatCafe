//
//  StartChat.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/28.
//

import FirebaseFirestore

// MARK: - startChat

func startChat(user1: User, user2: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.uid, user2Id: user2.uid)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    return chatRoomId
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    UserService.shared.fetchUsersBy(withIds: memberIds) { users in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: UserService.shared.currentUser!)!)
    return allUsers.first!
}

// MARK: - RecentChats

func createRecentItems(chatRoomId: String, users: [User]) {
    var memberIdsToCreateRecent = [users.first!.uid, users.last!.uid]
        
    // does user have recent?
    firebaseReference(.recent)
        .whereField(CCConstant.CHATROOMID, isEqualTo: chatRoomId)
        .getDocuments { (snapshot, _) in
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                // Updated members to create recent
                memberIdsToCreateRecent = removeMemberWhoHasRecent(
                    snapshot: snapshot,
                    memberIds: memberIdsToCreateRecent
                )
            }
            
            for userId in memberIdsToCreateRecent {
                guard let senderUser = userId == LocalStorage.shared.getUid()
                        ? UserService.shared.currentUser
                        : getReceiverFrom(users: users) else { return }
                
                guard let receiverUser = userId == LocalStorage.shared.getUid()
                        ? getReceiverFrom(users: users)
                        : UserService.shared.currentUser else { return }
                
                let recentObject = RecentChat(id: UUID().uuidString,
                                              chatRoomId: chatRoomId,
                                              senderId: senderUser.uid,
                                              senderName: senderUser.username,
                                              receiverId: receiverUser.uid,
                                              receiverName: receiverUser.username,
                                              date: Date(),
                                              memberIds: [senderUser.uid, receiverUser.uid],
                                              lastMessage: "",
                                              unreadCounter: 0,
                                              avatarLink: receiverUser.profileImageUrlString)
                
                RecentChatService.shared.saveRecent(recentObject)
            }
            
        }
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    var memberIdsToCreateRecent = memberIds
    
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[CCConstant.SENDERID] {
            // swiftlint:disable force_cast
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
            // swiftlint:enable force_cast
        }
    }
    
    return memberIdsToCreateRecent
}

func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    return chatRoomId
}
