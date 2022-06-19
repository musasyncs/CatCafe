//
//  NotificationCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

final class NotificationCell: UITableViewCell {
    
    var viewModel: NotificationViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.sd_setImage(with: viewModel.profileImageUrl)
            infoLabel.attributedText = viewModel.notificationMessage
            postImageView.sd_setImage(with: viewModel.photoUrl)
            
            followButton.isHidden = !viewModel.shouldHidePostImage
            postImageView.isHidden = viewModel.shouldHidePostImage
        }
    }
    
    lazy var  profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 36 / 2
        return imageView
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(postImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(recognizer)
        
        return imageView
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = .notoMedium(size: 12)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        selectionStyle = .none
        
        addSubview(profileImageView)
        addSubview(infoLabel)
        addSubview(followButton)
        addSubview(postImageView)
        
        profileImageView.setDimensions(height: 36, width: 36)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        infoLabel.centerY(inView: profileImageView,
                          leftAnchor: profileImageView.rightAnchor,
                          paddingLeft: 8)
        infoLabel.anchor(right: followButton.leftAnchor, paddingRight: 8)
        
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 8, width: 72, height: 32)
        
        postImageView.centerY(inView: self)
        postImageView.anchor(right: rightAnchor, paddingRight: 8, width: 40, height: 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    
    @objc func postImageTapped() {
        
    }
    
    @objc func followButtonTapped() {
        
    }
    
}
