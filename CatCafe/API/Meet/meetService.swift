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
                "title": title,
                "peopleCount": 0
            ]
            CCConstant.COLLECTION_MEETS.addDocument(data: dic, completion: completion)
        }
    }
    
    // MARK: - Fetch all meets / Fetch Meet with meet id
    
    static func fetchMeets(completion: @escaping(([Meet]) -> Void)) {
        CCConstant.COLLECTION_MEETS.order(by: "timestamp", descending: true).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let meets = documents.map { Meet(meetId: $0.documentID, dic: $0.data()) }
            completion(meets)
        }
    }
    
    static func fetchMeet(withMeetId meetId: String, completion: @escaping(Meet) -> Void) {
        CCConstant.COLLECTION_MEETS.document(meetId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let dic = snapshot.data() else { return }
            let meet = Meet(meetId: snapshot.documentID, dic: dic)
            completion(meet)
        }
    }
        
    // MARK: - Like a meet / UnLike a meet / Check if current user like a meet
    
    static func likeMeet(meet: Meet, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId).updateData(["likes": meet.likes + 1])
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId)
            .collection("meet-likes").document(currentUid).setData([:]) { _ in
                CCConstant.COLLECTION_USERS.document(currentUid)
                    .collection("user-meet-likes").document(meet.meetId).setData([:], completion: completion)
        }
    }
    
    static func unlikeMeet(meet: Meet, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        guard meet.likes > 0 else { return }
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId).updateData(["likes": meet.likes - 1])
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId)
            .collection("meet-likes").document(currentUid).delete { _ in
                CCConstant.COLLECTION_USERS.document(currentUid)
                    .collection("user-meet-likes").document(meet.meetId).delete(completion: completion)
            }
    }
    
    static func checkIfCurrentUserLikedMeet(meet: Meet, completion: @escaping(Bool) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_USERS.document(currentUid)
            .collection("user-meet-likes").document(meet.meetId).getDocument { snapshot, _ in
                guard let isLiked = snapshot?.exists else { return }
                completion(isLiked)
            }
    }
    
    // MARK: - Attend a meet / check if current user attended a Meet
    
    static func attendMeet(meet: Meet,
                           contact: String,
                           remarks: String,
                           completion: @escaping(FirestoreCompletion)
    ) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId).updateData(["peopleCount": meet.peopleCount + 1])
        
        let dic: [String: Any] = [
            "uid": currentUid,
            "contact": contact,
            "remarks": remarks,
            "timestamp": Timestamp(date: Date())
        ]
        
        CCConstant.COLLECTION_MEETS.document(meet.meetId)
            .collection("people").document(currentUid).setData(dic) { _ in
                
                CCConstant.COLLECTION_USERS.document(currentUid)
                    .collection("user-attend").document(meet.meetId).setData([:], completion: completion)
        }
    }
    
    static func checkIfCurrentUserAttendedMeet(meet: Meet, completion: @escaping(Bool) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        CCConstant.COLLECTION_USERS.document(currentUid)
            .collection("user-attend").document(meet.meetId).getDocument { snapshot, _ in
                guard let isAttended = snapshot?.exists else { return }
                completion(isAttended)
            }
    }
}
