//
//  CommentViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import UIKit

struct CommentViewModel {
    private let comment: Comment
    
    var profileImageUrlString: String? {
        return comment.user.profileImageUrlString
    }
    
    var username: String? {
        return comment.user.username
    }
    
    func makeCommentLabelText() -> NSAttributedString {
        guard let username = username else { return NSAttributedString(string: "") }
        
        let attrString = NSMutableAttributedString(
            string: "\(username)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.ccGrey
            ])
        attrString.append(NSAttributedString(
            string: comment.comment,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor.ccGrey
            ]))
        
        return attrString
    }
    
    init(comment: Comment) {
        self.comment = comment
    }

    func size(forWidth width: CGFloat) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = comment.comment
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
    }
}
