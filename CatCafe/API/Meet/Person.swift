//
//  Person.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/24.
//

import Firebase

struct Person {
    let contact: String
    let remarks: String
    let timestamp: Timestamp
    let uid: String
    
    init(dic: [String: Any]) {
        self.contact = dic["contact"] as? String ?? ""
        self.remarks = dic["remarks"] as? String ?? ""
        self.timestamp = dic["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.uid = dic["uid"] as? String ?? ""
    }
}
