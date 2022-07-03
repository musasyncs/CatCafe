//
//  ProfileCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

final class ProfileCell: UICollectionViewCell {
    
    var viewModel: PostViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            postImageView.sd_setImage(with: viewModel.mediaUrl)
        }
    }
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.lightGray
        addSubview(postImageView)
        postImageView.fillSuperView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
