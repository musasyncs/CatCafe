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
        meetDate: Date,
        completion: @escaping(FirestoreCompletion)
    ) {
        guard let uid = LocalStorage.shared.getUid() else { return }
        let directory = "Meet/" + "_\(uid)" + ".jpg"
        
        FileStorage.uploadImage(meetImage, directory: directory) { imageUrlString in
            let dic: [String: Any] = [
                "ownerUid": uid,
                "mediaType": 0,
                "mediaUrlString": imageUrlString,
                "caption": caption,
                "likes": 0,
                "timestamp": Timestamp(date: meetDate),
                "cafeId": cafeId,
                "cafeName": cafeName,
                "title": title,
                "peopleCount": 0
            ]
            firebaseReference(.meets).addDocument(data: dic, completion: completion)
        }
    }
    
    // MARK: - Fetch all meets / Fetch Meet with meet id / Fetch meets by uid / Fetch current user attended meets
    
    static func fetchMeets(completion: @escaping(([Meet]) -> Void)) {
        firebaseReference(.meets).order(by: "timestamp", descending: true).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let meets = documents.map { Meet(meetId: $0.documentID, dic: $0.data()) }
            completion(meets)
        }
    }
    
    static func fetchMeet(withMeetId meetId: String, completion: @escaping(Meet) -> Void) {
        firebaseReference(.meets).document(meetId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let dic = snapshot.data() else { return }
            let meet = Meet(meetId: snapshot.documentID, dic: dic)
            completion(meet)
        }
    }
    
    static func fetchMeets(forUser uid: String, completion: @escaping(([Meet]) -> Void)) {
        let query = firebaseReference(.meets).whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            var meets = documents.map { Meet(meetId: $0.documentID, dic: $0.data()) }
            meets.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(meets)
        }
    }
    
    static func fetchCurrentUserAttendMeets(completion: @escaping([Meet]) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.users)
            .document(currentUid)
            .collection("user-attend")
            .getDocuments { snapshot, _ in
            
            var meets = [Meet]()
            snapshot?.documents.forEach({ document in
                fetchMeet(withMeetId: document.documentID) { meet in
                    meets.append(meet)
                    meets.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    completion(meets)
                }
            })

            completion([Meet]())
        }
    }
        
    // MARK: - Like a meet / UnLike a meet / Check if current user like a meet
    
    static func likeMeet(meet: Meet, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.meets)
            .document(meet.meetId)
            .updateData(["likes": meet.likes + 1])
        
        firebaseReference(.meets)
            .document(meet.meetId)
            .collection("meet-likes")
            .document(currentUid).setData([:]) { _ in
                firebaseReference(.users)
                    .document(currentUid)
                    .collection("user-meet-likes")
                    .document(meet.meetId).setData([:], completion: completion)
        }
    }
    
    static func unlikeMeet(meet: Meet, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        guard meet.likes > 0 else { return }
        
        firebaseReference(.meets)
            .document(meet.meetId)
            .updateData(["likes": meet.likes - 1])
        
        firebaseReference(.meets)
            .document(meet.meetId)
            .collection("meet-likes")
            .document(currentUid).delete { _ in
                firebaseReference(.users)
                    .document(currentUid)
                    .collection("user-meet-likes")
                    .document(meet.meetId)
                    .delete(completion: completion)
            }
    }
    
    static func checkIfCurrentUserLikedMeet(meet: Meet, completion: @escaping(Bool) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.users)
            .document(currentUid)
            .collection("user-meet-likes")
            .document(meet.meetId)
            .getDocument { snapshot, _ in
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
        
        firebaseReference(.meets)
            .document(meet.meetId)
            .updateData(["peopleCount": meet.peopleCount + 1])
        
        let dic: [String: Any] = [
            "uid": currentUid,
            "contact": contact,
            "remarks": remarks,
            "timestamp": Timestamp(date: Date())
        ]
        
        firebaseReference(.meets)
            .document(meet.meetId)
            .collection("people")
            .document(currentUid).setData(dic) { _ in
                
                firebaseReference(.users)
                    .document(currentUid)
                    .collection("user-attend").document(meet.meetId).setData([:], completion: completion)
        }
    }
    
    static func checkIfCurrentUserAttendedMeet(meet: Meet, completion: @escaping(Bool) -> Void) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        firebaseReference(.users)
            .document(currentUid)
            .collection("user-attend").document(meet.meetId).getDocument { snapshot, _ in
                guard let isAttended = snapshot?.exists else { return }
                completion(isAttended)
            }
    }
    
    // MARK: - Fetch all people for a meet
        
    static func fetchPeople(
        forMeet meetId: String,
        completion: @escaping ([Person]) -> Void
    ) {
        var people = [Person]()
        
        let query = firebaseReference(.meets)
            .document(meetId)
            .collection("people")
            .order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, _ in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    let person = Person(dic: data)
                    people.append(person)
                }
            })
            
            completion(people)
        }
    }
    
}
