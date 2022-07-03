//
//  CommentViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import UIKit

struct CommentViewModel {
    
    private let comment: Comment
    
    var profileImageUrl: URL?
    var username: String?
    
    func makeCommentLabelText() -> NSAttributedString {
        guard let username = username else { return NSAttributedString(string: "") }
        
        let attrString = NSMutableAttributedString(
            string: "\(username)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.black
            ])
        attrString.append(NSAttributedString(
            string: comment.comment,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor.black
            ]))
        
        return attrString
    }
    
    init(comment: Comment) {
        self.comment = comment
    }

    // MARK: - Helpers
    
    func size(forWidth width: CGFloat) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = comment.comment
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
    }
}
