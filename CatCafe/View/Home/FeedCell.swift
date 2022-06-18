//
//  FeedCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell: FeedCell, showCommentsFor post: Post)
}

final class FeedCell: UICollectionViewCell {
    
    weak var delegate: FeedCellDelegate?
    
    var viewModel: PostViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.sd_setImage(with: viewModel.ownerImageUrl)
            usernameButton.setTitle(viewModel.ownerUsername, for: .normal)
            
            captionLabel.text = viewModel.caption
            postImageView.sd_setImage(with: viewModel.mediaUrl)
            likesLabel.text = viewModel.likesLabelText
        }
    }
    
    private let profileImageView = UIImageView()
    private lazy var usernameButton = UIButton(type: .system)
    private let postImageView = UIImageView()
    private lazy var likeButton = UIButton(type: .system)
    private lazy var commentButton = UIButton(type: .system)
    private lazy var shareButton = UIButton(type: .system)
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
//        profileImageView.image = UIImage(named: "me")
//        usernameButton.setTitle("ccw1130", for: .normal)
        usernameButton.addTarget(self, action: #selector(didTapUsername), for: .touchUpInside)
        postImageView.image = UIImage(named: "shin")
        likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
        commentButton.setImage(UIImage(named: "comment"), for: .normal)
        commentButton.addTarget(self, action: #selector(didTapComments), for: .touchUpInside)
        shareButton.setImage(UIImage(named: "send2"), for: .normal)
        likesLabel.text = "1 like"
        captionLabel.text = "Some test caption for now.."
        postTimeLabel.text = "2 days ago"
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
        likeButton.tintColor = .black
        commentButton.tintColor = .black
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
    @objc func didTapUsername() {
        print("DEBUG: Did tap username")
    }
    
    @objc func didTapComments() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, showCommentsFor: viewModel.post)
    }
    
}
