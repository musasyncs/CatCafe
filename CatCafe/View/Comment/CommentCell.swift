//
//  CommentCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import UIKit

final class CommentCell: UICollectionViewCell {
    
    var viewModel: CommentViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.sd_setImage(with: viewModel.profileImageUrl)
            commentLabel.attributedText = viewModel.makeCommentLabelText()
        }
    }
    
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
        label.numberOfLines = 0
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
        commentLabel.anchor(right: rightAnchor, paddingRight: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
