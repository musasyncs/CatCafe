//
//  Report.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/19.
//

import FirebaseFirestoreSwift

struct Report: Codable, Identifiable {
    @DocumentID var id: String?
    var postID: String = ""
    var uid: String = ""
    var message: String = ""
}
