//
//  ReportService.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/14.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class ReportService {
    
    static let shared = ReportService()
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
