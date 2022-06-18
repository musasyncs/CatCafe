//
//  CommentCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import UIKit

final class CommentCell: UICollectionViewCell {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 40 / 2
        return imageView
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        let attrString = NSMutableAttributedString(
            string: "吉岡里凡 ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ])
        attrString.append(NSAttributedString(
            string: "我是哈哈哈",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ]))
        label.attributedText = attrString
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(commentLabel)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
        profileImageView.setDimensions(height: 40, width: 40)
        commentLabel.centerY(inView: profileImageView,
                             leftAnchor: profileImageView.rightAnchor,
                             paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
