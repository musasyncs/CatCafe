//
//  ProfileHeaderViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

struct ProfileHeaderViewModel {
    var user: User
    
    var fullname: String {
        return user.fullname
    }
    var bioText: String {
        return user.bioText
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "編輯個人檔案"
        }
        return user.isFollowed ? "追蹤中" : "追蹤"
    }
    var followButtonTextColor: UIColor {
        if user.isCurrentUser {
            return .white
        } else if user.isFollowed {
            return .ccGrey
        } else {
            return .white
        }
    }
    var followButtonBackgroundColor: UIColor {
        if user.isCurrentUser {
            return .ccPrimary
        } else if user.isFollowed {
            return .white
        } else {
            return .ccPrimary
        }
    }
    var borderLineColor: CGColor {
        if user.isCurrentUser {
            return UIColor.ccPrimary.cgColor
        } else if user.isFollowed {
            return UIColor.ccGreyVariant.cgColor
        } else {
            return UIColor.ccPrimary.cgColor
        }
    }
    
    var numberOfFollowersAttrString: NSAttributedString {
        return attributedStatText(value: user.stats.followers, label: "粉絲")
    }
    var numberOfFollowingAttrString: NSAttributedString {
        return attributedStatText(value: user.stats.following, label: "追蹤中")
    }
    
    var blockButtonText: String {
        return user.isBlocked ? "解除封鎖" : "封鎖"
    }
    var blockButtonTextColor: UIColor {
        return user.isBlocked ? .ccGrey : .white
    }
    var blockButtonBackgroundColor: UIColor {
        return user.isBlocked ? .white : .ccSecondary
    }
    var blockButtonBorderLineColor: CGColor {
        return user.isBlocked ? UIColor.ccGreyVariant.cgColor : UIColor.ccSecondary.cgColor
    }
        
    init(user: User) {
        self.user = user
    }
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(value)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.ccGrey
            ])
        
        attributedText.append(NSAttributedString(
            string: label,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.ccGreyVariant
            ]))
        return attributedText
    }
    
}
