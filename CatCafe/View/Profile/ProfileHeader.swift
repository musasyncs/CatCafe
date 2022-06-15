//
//  ProfileHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import SDWebImage

class ProfileHeader: UICollectionReusableView {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "me")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.text = "Chi-Wen"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollowTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var postsLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attributedStatText(value: 5, label: "posts")
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attributedStatText(value: 2, label: "followers")
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attributedStatText(value: 1, label: "following")
        return label
    }()
    
    lazy var stack = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    lazy var buttonStack = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
    
    let topDivider = UIView()
    let bottomDivider = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Helpers
    
    func setupUI() {
        backgroundColor = .white
        stack.distribution = .fillEqually
        topDivider.backgroundColor = .lightGray
        bottomDivider.backgroundColor = .lightGray
        buttonStack.distribution = .fillEqually
    }
    
    func layout() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(editProfileFollowButton)
        addSubview(stack)
        addSubview(buttonStack)
        addSubview(topDivider)
        addSubview(bottomDivider)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 12)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        editProfileFollowButton.anchor(top: nameLabel.bottomAnchor,
                                       left: leftAnchor,
                                       right: rightAnchor,
                                       paddingTop: 16, paddingLeft: 24, paddingRight: 24)
        
        stack.centerY(inView: profileImageView)
        stack.anchor(left: profileImageView.rightAnchor,
                     right: rightAnchor,
                     paddingLeft: 12, paddingRight: 12, height: 50)
        
        buttonStack.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        
        topDivider.anchor(top: buttonStack.topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
        bottomDivider.anchor(top: buttonStack.bottomAnchor,
                             left: leftAnchor,
                             right: rightAnchor,
                             height: 0.5)
    }
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(value)\n",
            attributes: [.font: UIFont.systemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(
            string: label,
            attributes: [.font: UIFont.systemFont(ofSize: 14),
                         .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
        
    // MARK: - Action
    
    @objc func handleEditProfileFollowTapped() {
        
    }
}
