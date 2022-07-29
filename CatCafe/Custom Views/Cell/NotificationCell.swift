//
//  NotificationCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: NotificationCell, wantsToViewProfile uid: String)
    func cell(_ cell: NotificationCell, wantsToFollow uid: String)
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String)
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String)
}

class NotificationCell: UITableViewCell {
    
    weak var delegate: NotificationCellDelegate?
    
    var viewModel: NotificationViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.loadImage(viewModel.profileImageUrlString)
            infoLabel.attributedText = viewModel.notificationMessage
            postImageView.loadImage(viewModel.photoUrlString, placeHolder: UIImage.asset(.no_image))
            
            followButton.isHidden = !viewModel.shouldHidePostImage
            postImageView.isHidden = viewModel.shouldHidePostImage
            
            followButton.setTitle(viewModel.followButtonText, for: .normal)
            followButton.backgroundColor = viewModel.followButtonBackgroundColor
            followButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
            followButton.layer.borderColor = viewModel.borderLineColor
        }
    }
    
    // MARK: - View
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 36 / 2
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(recognizer)
        
        return imageView
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(postImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(recognizer)
        
        return imageView
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        selectionStyle = .none
        
        contentView.addSubviews(profileImageView, infoLabel, followButton, postImageView)        
        profileImageView.setDimensions(height: 36, width: 36)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        infoLabel.centerY(inView: profileImageView,
                          leftAnchor: profileImageView.rightAnchor,
                          paddingLeft: 8)
        infoLabel.anchor(right: followButton.leftAnchor, paddingRight: 8)
        
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 72, height: 32)
        
        postImageView.centerY(inView: self)
        postImageView.anchor(right: rightAnchor, paddingRight: 12, width: 40, height: 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    @objc func profileImageTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToViewProfile: viewModel.notification.fromUid)
    }
    
    @objc func postImageTapped() {
        guard let postId = viewModel?.notification.postId else { return }
        delegate?.cell(self, wantsToViewPost: postId)
    }
    
    @objc func followButtonTapped() {
        guard let viewModel = viewModel else { return }
        if viewModel.notification.userIsFollowed {
            delegate?.cell(self, wantsToUnfollow: viewModel.notification.fromUid)
        } else {
            delegate?.cell(self, wantsToFollow: viewModel.notification.fromUid)
        }
    }
    
}
