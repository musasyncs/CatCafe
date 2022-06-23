//
//  meetService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit
import Firebase

struct MeetService {
    
    // MARK: - Upload meet
    
    // swiftlint:disable:next function_parameter_count
    static func uploadMeet(
        title: String,
        caption: String,
        meetImage: UIImage,
        cafeId: String,
        cafeName: String,
        completion: @escaping(FirestoreCompletion)
    ) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        ImageUplader.uploadImage(for: .meet, image: meetImage) { imageUrlString in
            let dic: [String: Any] = [
                "ownerUid": uid,
                "mediaType": 0,
                "mediaUrlString": imageUrlString,
                "caption": caption,
                "likes": 0,
                "timestamp": Timestamp(date: Date()),
                "cafeId": cafeId,
                "cafeName": cafeName,
                "title": title
            ]
            CCConstant.COLLECTION_MEETS.addDocument(data: dic, completion: completion)
        }
    }
    
    // MARK: - Fetch all meets
    
    static func fetchMeets(completion: @escaping(([Meet]) -> Void)) {
        CCConstant.COLLECTION_MEETS.order(by: "timestamp", descending: true).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let meets = documents.map { Meet(meetId: $0.documentID, dic: $0.data()) }
            completion(meets)
        }
    }
        
    // MARK: - Like a meet / UnLike a meet / Check if current user like a meet
    
    static func likeMeet(meet: Meet, completion: @escaping(FirestoreCompletion)) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId).updateData(["likes": meet.likes + 1])
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId)
            .collection("meet-likes").document(uid).setData([:]) { _ in
                CCConstant.COLLECTION_USERS.document(uid)
                    .collection("user-meet-likes").document(meet.meetId).setData([:], completion: completion)
        }
    }
    
    static func unlikeMeet(meet: Meet, completion: @escaping(FirestoreCompletion)) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        guard meet.likes > 0 else { return }
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId).updateData(["likes": meet.likes - 1])
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId)
            .collection("meet-likes").document(uid).delete { _ in
                CCConstant.COLLECTION_USERS.document(uid)
                    .collection("user-meet-likes").document(meet.meetId).delete(completion: completion)
            }
    }
    
    static func checkIfCurrentUserLikedMeet(meet: Meet, completion: @escaping(Bool) -> Void) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_USERS.document(uid)
            .collection("user-meet-likes").document(meet.meetId).getDocument { snapshot, _ in
                guard let isLiked = snapshot?.exists else { return }
                completion(isLiked)
            }
    }
}
