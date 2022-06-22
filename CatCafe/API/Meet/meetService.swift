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
    
    // MARK: - Check if current user like a meet
    
    static func checkIfCurrentUserLikedMeet(meet: Meet, completion: @escaping(Bool) -> Void) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_USERS.document(uid)
            .collection("user-meet-likes").document(meet.meetId).getDocument { snapshot, _ in
                guard let isLiked = snapshot?.exists else { return }
                completion(isLiked)
            }
    }
}
