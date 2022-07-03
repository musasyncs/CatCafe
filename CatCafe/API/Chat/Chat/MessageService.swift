//
//  MessageService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class MessageService {
    
    static let shared = MessageService()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!

    private init() {}

    func checkForOldChats(_ documentId: String, collectionId: String, completion: @escaping ([LocalMessage]) -> Void) {
        firebaseReference(.messages)
            .document(documentId)
            .collection(collectionId)
            .getDocuments { (querySnapshot, _) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for old chats")
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: { $0.date < $1.date })
            
            completion(oldMessages)
        }
    }
    
    func listenForNewChats(_ documentId: String,
                           collectionId: String,
                           lastMessageDate: Date,
                           completion: @escaping((LocalMessage) -> Void)
    ) {
        newChatListener = firebaseReference(.messages)
            .document(documentId)
            .collection(collectionId)
            .whereField(
                CCConstant.DATE,
                isGreaterThan: lastMessageDate
            )
            .addSnapshotListener({ (querySnapshot, error) in
                
                guard let snapshot = querySnapshot else { return }
                
                for change in snapshot.documentChanges where change.type == .added {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            if message.senderId != LocalStorage.shared.getUid()! {
                                completion(message)
                            }
                        } else {
                            print("Document doesnt exist")
                        }
                        
                    case .failure(let error):
                        print("Error decoding local message: \(error.localizedDescription)")
                    }
                }
            })
    }
    
    func listenForReadStatusChange(_ documentId: String,
                                   collectionId: String,
                                   completion: @escaping (_ updatedMessage: LocalMessage) -> Void
    ) {
        updatedChatListener = firebaseReference(.messages)
            .document(documentId)
            .collection(collectionId)
            .addSnapshotListener({ (querySnapshot, error) in
                
                guard let snapshot = querySnapshot else { return }
                for change in snapshot.documentChanges where change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            completion(message)
                        } else {
                            print("Document does not exist chat")
                        }
                    case .failure(let error):
                        print("Error decoding local message: \(error)")
                    }
                    
                }
            })
    }
    
    // MARK: - Add, Update, Delete in Firebase
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            _ = try firebaseReference(.messages)
                .document(memberId)
                .collection(message.chatRoomId)
                .document(message.id)
                .setData(from: message)
        } catch {
            print("error saving message ", error.localizedDescription)
        }
    }

    func updateMessageInFireStore(_ message: LocalMessage, memberIds: [String]) {
        let values = [
            CCConstant.STATUS: CCConstant.READ,
            CCConstant.READDATE: Date()
        ] as [String: Any]

        for userId in memberIds {
            firebaseReference(.messages)
                .document(userId)
                .collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }

    func removeListeners() {
        self.newChatListener.remove()
        if self.updatedChatListener != nil {
            self.updatedChatListener.remove()
        }
    }
}
