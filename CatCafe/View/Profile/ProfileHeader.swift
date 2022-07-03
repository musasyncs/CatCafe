//
//  ProfileHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import SDWebImage

protocol ProfileHeaderDelegate: AnyObject {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
}

final class ProfileHeader: UICollectionReusableView {
    
    weak var delegate: ProfileHeaderDelegate?
    
    var viewModel: ProfileHeaderViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            nameLabel.text = viewModel.fullname
            profileImageView.sd_setImage(with: viewModel.profileImageUrl)
            
            editProfileFollowButton.setTitle(viewModel.followButtonText, for: .normal)
            editProfileFollowButton.backgroundColor = viewModel.followButtonBackgroundColor
            editProfileFollowButton.setTitleColor(viewModel.followButtonTextColor, for: .normal )
            
            postsLabel.attributedText = viewModel.numberOfPostsAttrString
            followersLabel.attributedText = viewModel.numberOfFollowersAttrString
            followingLabel.attributedText = viewModel.numberOfFollowingAttrString
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollowTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var stack = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        backgroundColor = .white
        stack.distribution = .fillEqually
    }
    
    func layout() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(stack)
        addSubview(editProfileFollowButton)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 12)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        stack.centerY(inView: profileImageView)
        stack.anchor(left: profileImageView.rightAnchor,
                     right: rightAnchor,
                     paddingLeft: 12, paddingRight: 12, height: 50)
        
        editProfileFollowButton.anchor(left: leftAnchor,
                                       bottom: bottomAnchor,
                                       right: rightAnchor,
                                       paddingLeft: 24, paddingBottom: 16, paddingRight: 24)
    }
    
    // MARK: - Action
    
    @objc func handleEditProfileFollowTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapActionButtonFor: viewModel.user)
    }
}
