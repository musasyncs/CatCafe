//
//  CommentSectionHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit

protocol CommentSectionHeaderDelegate: AnyObject {
    func didTapAttendButton(_ header: CommentSectionHeader)
    func didTapSeeAllPeopleButton(_ header: CommentSectionHeader)
}

class CommentSectionHeader: UICollectionReusableView {
    
    var viewModel: MeetViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
                        
            hostProfileImageView.loadImage(
                viewModel.ownerImageUrlString,
                placeHolder: UIImage.asset(.avatar)
            )            
            hostnameLabel.text = viewModel.ownerUsername
            seeAllPeopleButton.isHidden = viewModel.shouldHidePeopleButton
            
            titleLabel.text = viewModel.titleText
            
            descriptionLabel.text = viewModel.descriptionLabel
            
            timeLabel.text = viewModel.timestampText
            placeLabel.text = viewModel.locationText
            
            infoLabel.text = viewModel.infoText
            likeButton.tintColor = viewModel.likeButtonTintColor
            likeButton.setImage(viewModel.likeButtonImage, for: .normal)
            likesLabel.text = viewModel.likesLabelText
            
            attendButton.backgroundColor = viewModel.attendButtonBackgroundColor
            attendButton.isEnabled = viewModel.attendButtonEnabled
        }
    }
    
    weak var delegate: CommentSectionHeaderDelegate?
    
    private let hostProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24 / 2
        return imageView
    }()
    let hostnameLabel = UILabel()

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()

    let timeTitleLabel = UILabel()
    let timeLabel = UILabel()
    lazy var timeStackView = UIStackView(arrangedSubviews: [timeTitleLabel, timeLabel])
    
    let placeTitleLabel = UILabel()
    let placeLabel = UILabel()
    lazy var placeStackView = UIStackView(arrangedSubviews: [placeTitleLabel, placeLabel])

    let infoLabel = UILabel()
    lazy var likeButton = UIButton(type: .system)
    private let likesLabel = UILabel()
    
    let attendButton = makeTitleButton(withText: "報名聚會",
                                       font: .systemFont(ofSize: 15, weight: .regular),
                                       foregroundColor: .white,
                                       backgroundColor: .ccPrimary)
    let publicCommentLabel = UILabel()
    
    let seeAllPeopleButton = makeTitleButton(withText: "查看報名者",
                                             font: .systemFont(ofSize: 12, weight: .regular),
                                             foregroundColor: .ccPrimary, backgroundColor: .white,
                                             insets: .init(top: 5, left: 5, bottom: 5, right: 5),
                                             cornerRadius: 5, borderWidth: 1, borderColor: .ccPrimary)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Action
    
    @objc func seeAllPeople() {
        delegate?.didTapSeeAllPeopleButton(self)
    }
    
    @objc func handleAttendTapped() {
        delegate?.didTapAttendButton(self)
    }
    
}

extension CommentSectionHeader {
    
    func setup() {
        timeTitleLabel.text = "時間"
        placeTitleLabel.text = "地點"
        publicCommentLabel.text = "公開留言"
        
        attendButton.addTarget(self, action: #selector(handleAttendTapped), for: .touchUpInside)
        seeAllPeopleButton.addTarget(self, action: #selector(seeAllPeople), for: .touchUpInside)
    }
    
    func style() {
        backgroundColor = .white
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .ccGrey
        descriptionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .ccGrey
        timeTitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        timeTitleLabel.textColor = .systemGray
        timeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        timeLabel.textColor = .ccGrey
        placeTitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        placeTitleLabel.textColor = .systemGray
        placeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        placeLabel.textColor = .ccGrey
        
        timeStackView.axis = .horizontal
        timeStackView.alignment = .center
        timeStackView.spacing = 16
        
        placeStackView.axis = .horizontal
        placeStackView.alignment = .center
        placeStackView.spacing = 16
        
        hostnameLabel.font = .systemFont(ofSize: 11, weight: .regular)
        hostnameLabel.textColor = .ccGrey
        infoLabel.font = .systemFont(ofSize: 12, weight: .regular)
        infoLabel.textColor = .systemGray
        
        likeButton.setImage(UIImage.asset(.like_unselected), for: .normal)
        likeButton.tintColor = .ccGrey
        likesLabel.font = .systemFont(ofSize: 10, weight: .regular)
        likesLabel.textColor = .ccGrey
        
        publicCommentLabel.font = .systemFont(ofSize: 12, weight: .medium)
        publicCommentLabel.textColor = .ccGrey
    }
    
    // swiftlint:disable all
    func layout() {
        addSubview(hostProfileImageView)
        addSubview(hostnameLabel)
        addSubview(seeAllPeopleButton)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(timeStackView)
        addSubview(placeStackView)
        addSubview(infoLabel)
        addSubview(likeButton)
        addSubview(likesLabel)
        addSubview(attendButton)
        addSubview(publicCommentLabel)
        
        hostProfileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        hostProfileImageView.setDimensions(height: 24, width: 24)
        hostnameLabel.centerY(inView: hostProfileImageView,
                              leftAnchor: hostProfileImageView.rightAnchor,
                              paddingLeft: 8)
        seeAllPeopleButton.centerY(inView: hostnameLabel)
        seeAllPeopleButton.anchor(right: rightAnchor, paddingRight: 16)
        
        titleLabel.anchor(top: hostProfileImageView.bottomAnchor,
                          left: hostProfileImageView.leftAnchor,
                          right: rightAnchor,
                          paddingTop: 16, paddingRight: 16)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor,
                                left: hostProfileImageView.leftAnchor,
                                right: rightAnchor,
                                paddingTop: 16, paddingRight: 16)
        timeStackView.anchor(top: descriptionLabel.bottomAnchor,
                             left: hostProfileImageView.leftAnchor,
                             paddingTop: 16)
        placeStackView.anchor(top: timeStackView.bottomAnchor,
                              left: hostProfileImageView.leftAnchor,
                              paddingTop: 8)
        
        likeButton.anchor(top: placeStackView.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingRight: 16)
        likesLabel.anchor(left: likeButton.rightAnchor, bottom: likeButton.bottomAnchor, paddingBottom: -4)
        
        infoLabel.anchor(right: likeButton.leftAnchor, paddingRight: 8)
        infoLabel.centerY(inView: likeButton)
        
        attendButton.anchor(top: likesLabel.bottomAnchor,
                            left: leftAnchor,
                            right: rightAnchor,
                            paddingTop: 16,
                            height: 50)
        publicCommentLabel.anchor(top: attendButton.bottomAnchor,
                                  left: leftAnchor,
                                  bottom: bottomAnchor,
                                  paddingTop: 16, paddingLeft: 8, paddingBottom: 8)
    }
    // swiftlint:enable all
}
