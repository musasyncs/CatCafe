//
//  FeedCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String)
    func cell(_ cell: FeedCell, didLike post: Post)
    func cell(_ cell: FeedCell, showCommentsFor post: Post)
}

final class FeedCell: UICollectionViewCell {
    
    weak var delegate: FeedCellDelegate?
    
    var viewModel: PostViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.loadImage(viewModel.ownerImageUrlString, placeHolder: UIImage.asset(.avatar))
            usernameButton.setTitle(viewModel.ownerUsername, for: .normal)
            locationButton.setTitle(viewModel.locationText, for: .normal)
            postImageView.loadImage(viewModel.mediaUrlString, placeHolder: UIImage.asset(.no_image))
            
            likeButton.tintColor = viewModel.likeButtonTintColor
            likeButton.setImage(viewModel.likeButtonImage, for: .normal)
            likesLabel.text = viewModel.likesLabelText
            commentLabel.text = viewModel.commentCountText
            
            captionLabel.attributedText = viewModel.makeCaptionText()
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
    private lazy var postImageView = UIImageView()
    
    private lazy var blurControlView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private lazy var controlStackView = UIStackView(arrangedSubviews: [likeView, commentView])
    private lazy var likeView = UIView()
    private lazy var likeStackView = UIStackView(arrangedSubviews: [likeButton, likesLabel])
    private lazy var likeButton = UIButton(type: .system)
    private lazy var likesLabel = UILabel()
    private lazy var commentView = UIView()
    private lazy var commentStackView = UIStackView(arrangedSubviews: [commentButton, commentLabel])
    private lazy var commentButton = UIButton(type: .system)
    private lazy var commentLabel = UILabel()
    
    private lazy var captionLabel = UILabel()
    private lazy var postTimeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    func setup() {
        usernameButton.addTarget(self, action: #selector(showUserProfile), for: .touchUpInside)        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComments), for: .touchUpInside)
    }
    
    func setupUI() {
        backgroundColor = .white
        usernameButton.setTitleColor(.ccGrey, for: .normal)
        usernameButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        locationButton.setTitleColor(.ccGreyVariant, for: .normal)
        locationButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        infoStackView.axis = .vertical
        infoStackView.distribution = .fillEqually
        infoStackView.spacing = 2
        infoStackView.alignment = .leading
        
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.isUserInteractionEnabled = true
        
        blurControlView.alpha = 0.9
        blurControlView.layer.cornerRadius = 50 / 2
        blurControlView.layer.masksToBounds = true
        controlStackView.backgroundColor = .clear
        controlStackView.axis = .horizontal
        controlStackView.spacing = 0
        controlStackView.distribution = .fillEqually
        controlStackView.alignment = .center
        
        likeView.backgroundColor = .white.withAlphaComponent(0.9)
        likeView.layer.cornerRadius = 34 / 2
        likeView.layer.masksToBounds = true
        likeStackView.backgroundColor = .clear
        likeStackView.axis = .horizontal
        likeStackView.spacing = 5
        likeStackView.distribution = .fillEqually
        likeStackView.alignment = .center
        likeButton.setImage(
            UIImage.asset(.like_unselected)?
                .resize(to: .init(width: 24, height: 24)),
            for: .normal
        )
        likeButton.tintColor = .ccGrey
        likesLabel.font = .systemFont(ofSize: 13, weight: .medium)
        likesLabel.textColor = .ccGrey
        likesLabel.textAlignment = .center
        likesLabel.numberOfLines = 1
        
        commentView.backgroundColor = .clear
        commentView.layer.masksToBounds = true
        commentStackView.backgroundColor = .clear
        commentStackView.axis = .horizontal
        commentStackView.spacing = 5
        commentStackView.distribution = .fillEqually
        commentStackView.alignment = .center
        commentButton.setImage(
            UIImage.asset(.comment)?
                .resize(to: .init(width: 24, height: 24)),
            for: .normal
        )
        commentButton.tintColor = .ccGrey
        commentLabel.font = .systemFont(ofSize: 13, weight: .medium)
        commentLabel.textColor = .ccGrey
        commentLabel.textAlignment = .center
        commentLabel.numberOfLines = 1
        commentLabel.text = "34"
        
        captionLabel.numberOfLines = 0
        postTimeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        postTimeLabel.textColor = .lightGray
    }
    
    func layout() {
        addSubview(profileImageView)
        addSubview(infoStackView)
        addSubview(postImageView)
        addSubview(blurControlView)
        addSubview(controlStackView)
        addSubview(likeStackView)
        addSubview(commentStackView)
        addSubview(captionLabel)
        addSubview(postTimeLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 15)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        infoStackView.anchor(left: profileImageView.rightAnchor, paddingLeft: 15)
        infoStackView.centerY(inView: profileImageView)
        usernameButton.setHeight(16)
        locationButton.setHeight(16)
        
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        blurControlView.anchor(left: postImageView.leftAnchor,
                               bottom: postImageView.bottomAnchor,
                               paddingLeft: 16, paddingBottom: 10,
                               width: 165 + 7 + 7, height: 50)
        controlStackView.anchor(top: blurControlView.topAnchor,
                                left: blurControlView.leftAnchor,
                                bottom: blurControlView.bottomAnchor,
                                paddingTop: 8, paddingLeft: 8, paddingBottom: 8, width: 164)
        likeView.setDimensions(height: 34, width: 82)
        commentView.setDimensions(height: 34, width: 82)
        
        likeStackView.anchor(top: likeView.topAnchor,
                             left: likeView.leftAnchor,
                             bottom: likeView.bottomAnchor,
                             right: likeView.rightAnchor,
                             paddingTop: 5, paddingLeft: 14, paddingBottom: 5, paddingRight: 14)
        commentStackView.anchor(top: commentView.topAnchor,
                                left: commentView.leftAnchor,
                                bottom: commentView.bottomAnchor,
                                right: commentView.rightAnchor,
                                paddingTop: 5, paddingLeft: 14, paddingBottom: 5, paddingRight: 14)
        likesLabel.setDimensions(height: 25, width: 15)
        commentLabel.setDimensions(height: 25, width: 15)

        captionLabel.anchor(top: postImageView.bottomAnchor,
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
