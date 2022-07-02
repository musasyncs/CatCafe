//
//  Cafe.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

struct Cafe {
    let address: String
    let id: String
    let lat: Double
    let long: Double
    let phoneNumber: String
    let title: String
    let website: String
    
    var isSelected: Bool = false
        
    init(dic: [String: Any]) {
        self.address = dic["address"] as? String ?? ""
        self.id = dic["id"] as? String ?? ""
        self.lat = dic["lat"] as? Double ?? 0
        self.long = dic["long"] as? Double ?? 0
        self.phoneNumber = dic["phoneNumber"] as? String ?? ""
        self.title = dic["title"] as? String ?? ""
        self.website = dic["website"] as? String ?? ""
    }
}
