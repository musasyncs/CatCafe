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
            postImageView.sd_setImage(with: viewModel.mediaUrl)
            
            likeButton.tintColor = viewModel.likeButtonTintColor
            likeButton.setImage(viewModel.likeButtonImage, for: .normal)
            likesLabel.text = viewModel.likesLabelText
            
            captionLabel.text = viewModel.caption
            postTimeLabel.text = viewModel.timestampText
        }
    }
    
    private let profileImageView = UIImageView()
    private lazy var usernameButton = UIButton(type: .system)
    private let postImageView = UIImageView()
    lazy var likeButton = UIButton(type: .system)
    lazy var commentButton = UIButton(type: .system)
    lazy var shareButton = UIButton(type: .system)
    private lazy var stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
    private let likesLabel = UILabel()
    private let captionLabel = UILabel()
    private let postTimeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupUI()
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
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(recognizer)
    }
    
    func setupUI() {
        backgroundColor = .white
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.backgroundColor = .lightGray
        usernameButton.setTitleColor(.black, for: .normal)
        usernameButton.titleLabel?.font = .notoMedium(size: 13)
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.isUserInteractionEnabled = true
        likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
        likeButton.tintColor = .black
        commentButton.setImage(UIImage(named: "comment"), for: .normal)
        commentButton.tintColor = .black
        shareButton.setImage(UIImage(named: "send2"), for: .normal)
        shareButton.tintColor = .black
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        likesLabel.font = .systemFont(ofSize: 13, weight: .medium)
        captionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        postTimeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        postTimeLabel.textColor = .lightGray
    }
    
    func layout() {
        addSubview(profileImageView)
        addSubview(usernameButton)
        addSubview(postImageView)
        addSubview(stackView)
        addSubview(likesLabel)
        addSubview(captionLabel)
        addSubview(postTimeLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        usernameButton.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        stackView.anchor(top: postImageView.bottomAnchor, width: 120, height: 50)
        likesLabel.anchor(top: stackView.bottomAnchor, left: leftAnchor, paddingTop: 0, paddingLeft: 8)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
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
