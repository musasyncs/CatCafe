//
//  ProfileHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit
import Lottie

protocol ProfileHeaderDelegate: AnyObject {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
    func header(_ profileHeader: ProfileHeader, wantToChatWith user: User)
    func header(_ profileHeader: ProfileHeader, didTapBlock user: User)
}

final class ProfileHeader: UICollectionReusableView {
    
    weak var delegate: ProfileHeaderDelegate?
    
    var viewModel: ProfileHeaderViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            followersLabel.attributedText = viewModel.numberOfFollowersAttrString
            followingLabel.attributedText = viewModel.numberOfFollowingAttrString
            
            nameLabel.text = viewModel.fullname
            bioLabel.text = viewModel.bioText
        
            editProfileFollowButton.setTitle(viewModel.followButtonText, for: .normal)
            editProfileFollowButton.backgroundColor = viewModel.followButtonBackgroundColor
            editProfileFollowButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
            editProfileFollowButton.layer.borderColor = viewModel.borderLineColor
            
            blockButton.setTitle(viewModel.blockButtonText, for: .normal)
            blockButton.backgroundColor = viewModel.blockButtonBackgroundColor
            blockButton.setTitleColor(viewModel.blockButtonTextColor, for: .normal)
            blockButton.layer.borderColor = viewModel.blockButtonBorderLineColor
            
            if viewModel.user == UserService.shared.currentUser {
                buttonStackView.addArrangedSubview(editProfileFollowButton)
            } else {
                buttonStackView.addArrangedSubview(editProfileFollowButton)
                buttonStackView.addArrangedSubview(goChatButton)
                buttonStackView.addArrangedSubview(blockButton)
            }
        }
    }
    
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .ccGrey
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .ccGreyVariant
        return label
    }()
    
    private lazy var editProfileFollowButton = makeTitleButton(
        withText: "",
        font: .systemFont(ofSize: 14, weight: .medium),
        kern: 0,
        foregroundColor: .white,
        backgroundColor: .ccPrimary,
        insets: .init(top: 12, left: 30, bottom: 12, right: 30),
        cornerRadius: 40 / 2,
        borderWidth: 1, borderColor: .ccPrimary
    )
    
    private lazy var goChatButton = makeTitleButton(
        withText: "發訊息",
        font: .systemFont(ofSize: 14, weight: .medium),
        kern: 0,
        foregroundColor: .ccGrey,
        backgroundColor: .white,
        insets: .init(top: 12, left: 30, bottom: 12, right: 30),
        cornerRadius: 40 / 2,
        borderWidth: 1, borderColor: .white
    )
    
    private lazy var blockButton = makeTitleButton(
        withText: "",
        font: .systemFont(ofSize: 14, weight: .medium),
        kern: 0,
        foregroundColor: .white,
        backgroundColor: .ccSecondary,
        insets: .init(top: 12, left: 10, bottom: 12, right: 10),
        cornerRadius: 40 / 2,
        borderWidth: 1, borderColor: .ccSecondary
    )
    
    private lazy var buttonStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        editProfileFollowButton.addTarget(self, action: #selector(handleEditProfileFollowTapped), for: .touchUpInside)
        
        goChatButton.addTarget(self, action: #selector(goChat), for: .touchUpInside)
        goChatButton.layer.shadowColor = UIColor.ccGrey.cgColor
        goChatButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        goChatButton.layer.shadowOpacity = 0.05
        goChatButton.layer.shadowRadius = 2
        goChatButton.layer.masksToBounds = false
        
        blockButton.addTarget(self, action: #selector(handleBlockUser), for: .touchUpInside)
        
        buttonStackView.alignment = .center
        buttonStackView.distribution = .equalSpacing
        buttonStackView.alignment = .center
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func layout() {
        addSubview(followersLabel)
        addSubview(followingLabel)
        addSubview(nameLabel)
        addSubview(bioLabel)
        addSubview(buttonStackView)
        
        followersLabel.anchor(
            top: topAnchor,
            left: leftAnchor,
            paddingTop: 18,
            paddingLeft: 50
        )
        
        followingLabel.anchor(
            top: topAnchor,
            right: rightAnchor,
            paddingTop: 18,
            paddingRight: 50
        )
        
        nameLabel.anchor(
            top: topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 78,
            paddingLeft: 24,
            paddingRight: 24
        )
        nameLabel.centerX(inView: self)
        
        bioLabel.anchor(
            top: nameLabel.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 4,
            paddingLeft: 90,
            paddingRight: 90
        )
        bioLabel.centerX(inView: self)
        
        buttonStackView.anchor(
            top: bioLabel.bottomAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            paddingTop: 17,
            paddingLeft: 18,
            paddingBottom: 8,
            paddingRight: 18
        )
        editProfileFollowButton.setDimensions(height: 40, width: 125)
        goChatButton.setDimensions(height: 40, width: 125)
        blockButton.setDimensions(height: 40, width: 80)
        
    }
    
    // MARK: - Action
    @objc func handleEditProfileFollowTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapActionButtonFor: viewModel.user)
    }
    
    @objc func goChat() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, wantToChatWith: viewModel.user)
    }
    
    @objc func handleBlockUser() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapBlock: viewModel.user)
    }
    
}
