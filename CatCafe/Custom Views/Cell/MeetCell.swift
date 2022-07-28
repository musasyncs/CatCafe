//
//  MeetCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit

protocol MeetCellDelegate: AnyObject {
    func cell(_ cell: MeetCell, didLike meet: Meet)
}

class MeetCell: UICollectionViewCell {
    
    weak var delegate: MeetCellDelegate?
    
    var viewModel: MeetViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            meetImageView.loadImage(viewModel.mediaUrlString)
            
            titleLabel.text = viewModel.titleText
            timeLabel.text = viewModel.timestampText
            placeLabel.text = viewModel.locationText
            
            hostProfileImageView.loadImage(viewModel.ownerImageUrlString)
            hostnameLabel.text = viewModel.ownerUsername
            
            infoLabel.text = viewModel.infoText
            likeButton.tintColor = viewModel.likeButtonTintColor
            likeButton.setImage(viewModel.likeButtonImage, for: .normal)
            likesLabel.text = viewModel.likesLabelText
        }
    }
    
    // MARK: - View
    private let meetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .gray6
        return imageView
    }()
    
    private let titleLabel = UILabel()
    
    private let timeTitleLabel = UILabel()
    private let timeLabel = UILabel()
    private lazy var timeStackView = UIStackView(arrangedSubviews: [timeTitleLabel, timeLabel])
    
    private let placeTitleLabel = UILabel()
    private let placeLabel = UILabel()
    private lazy var placeStackView = UIStackView(arrangedSubviews: [placeTitleLabel, placeLabel])
    
    private let hostProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24 / 2
        imageView.backgroundColor = .gray6
        return imageView
    }()
    private let hostnameLabel = UILabel()
    private let infoLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    private let likesLabel = UILabel()
        
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
    @objc func didTapLike() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didLike: viewModel.meet)
    }
    
}

extension MeetCell {
    
    private func setup() {
        timeTitleLabel.text = "時間"
        placeTitleLabel.text = "地點"
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    }
    
    private func style() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.ccGrey.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .ccGrey
        timeTitleLabel.font = .systemFont(ofSize: 10, weight: .regular)
        timeTitleLabel.textColor = .systemGray
        timeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        timeLabel.textColor = .ccGrey
        placeTitleLabel.font = .systemFont(ofSize: 10, weight: .regular)
        placeTitleLabel.textColor = .systemGray
        placeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        placeLabel.textColor = .ccGrey
        
        timeStackView.axis = .horizontal
        timeStackView.alignment = .center
        timeStackView.spacing = 8
        
        placeStackView.axis = .horizontal
        placeStackView.alignment = .center
        placeStackView.spacing = 8
        
        hostnameLabel.font = .systemFont(ofSize: 11, weight: .regular)
        hostnameLabel.textColor = .ccGrey
        infoLabel.font = .systemFont(ofSize: 12, weight: .regular)
        infoLabel.textColor = .systemGray
        
        likeButton.setImage(UIImage.asset(.like_unselected), for: .normal)
        likeButton.tintColor = .ccGrey
        likesLabel.font = .systemFont(ofSize: 10, weight: .regular)
        likesLabel.textColor = .ccGrey
    }
    
    private func layout() {
        addSubviews(meetImageView, titleLabel, timeStackView,
                    placeStackView, hostProfileImageView,
                    hostnameLabel, infoLabel, likeButton, likesLabel)
        
        meetImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        meetImageView.setDimensions(height: 112, width: 112)
        
        titleLabel.anchor(top: meetImageView.topAnchor,
                          left: meetImageView.rightAnchor,
                          right: rightAnchor,
                          paddingLeft: 8, paddingRight: 8)
        timeStackView.anchor(top: titleLabel.bottomAnchor,
                             left: meetImageView.rightAnchor,
                             paddingTop: 8, paddingLeft: 8)
        placeStackView.anchor(top: timeStackView.bottomAnchor,
                              left: meetImageView.rightAnchor,
                              paddingTop: 8, paddingLeft: 8)
        hostProfileImageView.anchor(top: placeStackView.bottomAnchor,
                                    left: placeStackView.leftAnchor,
                                    paddingTop: 8)
        hostProfileImageView.setDimensions(height: 24, width: 24)
        hostnameLabel.centerY(inView: hostProfileImageView,
                              leftAnchor: hostProfileImageView.rightAnchor,
                              paddingLeft: 8)
        likeButton.anchor(top: hostnameLabel.bottomAnchor,
                          right: rightAnchor,
                          paddingTop: 8, paddingRight: 16)
        likesLabel.anchor(left: likeButton.rightAnchor,
                          bottom: likeButton.bottomAnchor,
                          paddingBottom: -4)
        infoLabel.anchor(right: likeButton.leftAnchor, paddingRight: 8)
        infoLabel.centerY(inView: likeButton)
    }
    
}
