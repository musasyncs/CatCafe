//
//  ReportManager.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/14.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Report: Codable, Identifiable {
    @DocumentID var id: String?
    var postID: String = ""
    var uid: String = ""
    var message: String = ""
}

class ReportManager {
    
    static let shared = ReportManager()
    private init() {}
    
    func sendReport(postId: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let report = Report(
            postID: postId,
            uid: LocalStorage.shared.getUid() ?? "",
            message: message
        )
        do {
            _ = try firebaseReference(.reports).addDocument(from: report)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
}
