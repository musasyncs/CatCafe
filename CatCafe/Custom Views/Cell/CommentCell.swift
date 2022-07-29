//
//  CommentCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var viewModel: CommentViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.loadImage(viewModel.profileImageUrlString)
            commentLabel.attributedText = viewModel.makeCommentLabelText()
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray6
        imageView.layer.cornerRadius = 24 / 2
        return imageView
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubviews(profileImageView, commentLabel)
        profileImageView.anchor(top: topAnchor,
                                left: leftAnchor,
                                paddingTop: 8,
                                paddingLeft: 8)
        profileImageView.setDimensions(height: 24, width: 24)
        
        commentLabel.anchor(top: profileImageView.topAnchor,
                            left: profileImageView.rightAnchor,
                            bottom: bottomAnchor,
                            right: rightAnchor,
                            paddingLeft: 8, paddingRight: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
