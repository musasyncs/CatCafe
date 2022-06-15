//
//  ProfileHeaderViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import Foundation
import UIKit

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonTextColor: UIColor {
        if user.isCurrentUser {
            return .black
        } else if user.isFollowed {
            return .black
        } else {
            return .white
        }
    }
    
    var followButtonBackgroundColor: UIColor {
        if user.isCurrentUser {
            return .white
        } else if user.isFollowed {
            return .white
        } else {
            return .systemBlue
        }
    }

    init(user: User) {
        self.user = user
    }
}
