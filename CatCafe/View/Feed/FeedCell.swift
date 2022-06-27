//
//  FeedCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell: FeedCell, showCommentsFor post: Post)
    func cell(_ cell: FeedCell, didLike post: Post)
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String)
}

final class FeedCell: UICollectionViewCell {
    
    weak var delegate: FeedCellDelegate?
    
    var viewModel: PostViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.sd_setImage(with: viewModel.ownerImageUrl)
            usernameButton.setTitle(viewModel.ownerUsername, for: .normal)
            locationButton.setTitle(viewModel.locationText, for: .normal)
            postImageView.sd_setImage(with: viewModel.mediaUrl)
            
            likeButton.tintColor = viewModel.likeButtonTintColor
            likeButton.setImage(viewModel.likeButtonImage, for: .normal)
            likesLabel.text = viewModel.likesLabelText
            
            captionLabel.text = viewModel.caption
            postTimeLabel.text = viewModel.timestampText
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .lightGray
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(recognizer)
        return imageView
    }()
    
    private lazy var usernameButton = UIButton(type: .system)
    private lazy var locationButton = UIButton(type: .system)
    private lazy var infoStackView = UIStackView(arrangedSubviews: [usernameButton, locationButton])
    private let postImageView = UIImageView()
    lazy var likeButton = UIButton(type: .system)
    lazy var commentButton = UIButton(type: .system)
    private lazy var controlStackView = UIStackView(arrangedSubviews: [likeButton, commentButton])
    private let likesLabel = UILabel()
    private let captionLabel = UILabel()
    private let postTimeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        configureUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func setup() {
        usernameButton.addTarget(self, action: #selector(showUserProfile), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComments), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    }
    
    func configureUI() {
        backgroundColor = .white
        usernameButton.setTitleColor(.black, for: .normal)
        usernameButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        locationButton.setTitleColor(.systemBrown, for: .normal)
        locationButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
        infoStackView.axis = .vertical
        infoStackView.distribution = .fillEqually
        infoStackView.spacing = 4
        infoStackView.alignment = .leading
        
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.isUserInteractionEnabled = true
        
        likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
        likeButton.tintColor = .black
        commentButton.setImage(UIImage(named: "comment"), for: .normal)
        commentButton.tintColor = .black
        controlStackView.axis = .horizontal
        controlStackView.spacing = 16
        controlStackView.distribution = .fillEqually
        
        likesLabel.font = .systemFont(ofSize: 13, weight: .medium)
        likesLabel.textColor = .black
        captionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        captionLabel.textColor = .black
        captionLabel.numberOfLines = 0
        postTimeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        postTimeLabel.textColor = .lightGray
    }
    
    func layout() {
        addSubview(profileImageView)
        addSubview(infoStackView)
        addSubview(postImageView)
        addSubview(controlStackView)
        addSubview(likesLabel)
        addSubview(captionLabel)
        addSubview(postTimeLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        infoStackView.anchor(left: profileImageView.rightAnchor, paddingLeft: 8)
        infoStackView.centerY(inView: profileImageView)
        usernameButton.setHeight(16)
        locationButton.setHeight(16)
        
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        controlStackView.anchor(top: postImageView.bottomAnchor,
                                left: leftAnchor,
                                paddingTop: 4,
                                paddingLeft: 8,
                                height: 40)
        likesLabel.anchor(top: controlStackView.bottomAnchor,
                          left: leftAnchor,
                          paddingLeft: 8,
                          height: 16)
        captionLabel.anchor(top: likesLabel.bottomAnchor,
                            left: leftAnchor,
                            right: rightAnchor,
                            paddingTop: 8, paddingLeft: 8, paddingRight: 8)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor,
                             left: leftAnchor,
                             bottom: bottomAnchor,
                             paddingTop: 8, paddingLeft: 8, paddingBottom: 8,
                             height: 16)
    }
    
    // MARK: - Action
    @objc func showUserProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowProfileFor: viewModel.post.ownerUid)
    }
    
    @objc func didTapComments() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, showCommentsFor: viewModel.post)
    }
    
    @objc func didTapLike() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didLike: viewModel.post)
    }
}
