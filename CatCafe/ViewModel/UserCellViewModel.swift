//
//  UserCellViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Foundation

struct UserCellViewModel {
    var user: User
    
    var profileImageUrl: String {
        return user.profileImageUrlString
    }
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    init(user: User) {
        self.user = user
    }
}
