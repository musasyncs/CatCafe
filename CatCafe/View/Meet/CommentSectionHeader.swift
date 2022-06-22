//
//  CommentSectionHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit

protocol CommentSectionHeaderDelegate: AnyObject {
    func didTapAttendButton(_ header: CommentSectionHeader)
}

class CommentSectionHeader: UICollectionReusableView {
    
    weak var delegate: CommentSectionHeaderDelegate?
    
    private let hostProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cutecat")
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
    let attendButton = makeTitleButton(withText: "報名聚會",
                                       font: .notoRegular(size: 15),
                                       foregroundColor: .white,
                                       backgroundColor: .systemBrown)
    let publicCommentLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Helpers
    
    func setup() {
        titleLabel.text = "春Land"
        descriptionLabel.text = "JHIFTYU FVTF FTYU FVTFFTYU FVTFFTYU FVTFFTYU FVTF"
        timeTitleLabel.text = "時間"
        timeLabel.text = "06/25 19:00"
        placeTitleLabel.text = "地點"
        placeLabel.text = "Legacy Taipei"
        hostnameLabel.text = "阿布"
        infoLabel.text = "5人報名 | 1則留言"
        publicCommentLabel.text = "公開留言"
        
        attendButton.addTarget(self, action: #selector(handleAttendTapped), for: .touchUpInside)
    }
    
    func style() {
        backgroundColor = .white
        
        titleLabel.font = .notoRegular(size: 15)
        descriptionLabel.font = .notoRegular(size: 11)
        timeTitleLabel.font = .notoRegular(size: 11)
        timeTitleLabel.textColor = .systemGray
        timeLabel.font = .notoRegular(size: 11)
        placeTitleLabel.font = .notoRegular(size: 11)
        placeTitleLabel.textColor = .systemGray
        placeLabel.font = .notoRegular(size: 11)
        
        timeStackView.axis = .horizontal
        timeStackView.alignment = .center
        timeStackView.spacing = 32
        
        placeStackView.axis = .horizontal
        placeStackView.alignment = .center
        placeStackView.spacing = 32
        
        hostnameLabel.font = .notoRegular(size: 11)
        infoLabel.font = .notoRegular(size: 12)
        infoLabel.textColor = .systemGray
        
        publicCommentLabel.font = .notoMedium(size: 12)
        publicCommentLabel.textColor = .greyishBrown
    }
    
    func layout() {
        addSubview(hostProfileImageView)
        addSubview(hostnameLabel)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(timeStackView)
        addSubview(placeStackView)
        addSubview(infoLabel)
        addSubview(attendButton)
        addSubview(publicCommentLabel)
        
        hostProfileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        hostProfileImageView.setDimensions(height: 24, width: 24)
        hostnameLabel.centerY(inView: hostProfileImageView,
                              leftAnchor: hostProfileImageView.rightAnchor,
                              paddingLeft: 8)
        titleLabel.anchor(top: hostProfileImageView.bottomAnchor, left: hostProfileImageView.leftAnchor, paddingTop: 16)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor,
                                left: hostProfileImageView.leftAnchor,
                                right: rightAnchor,
                                paddingTop: 16,
                                paddingRight: 16)
        timeStackView.anchor(top: descriptionLabel.bottomAnchor,
                             left: hostProfileImageView.leftAnchor,
                             paddingTop: 16)
        placeStackView.anchor(top: timeStackView.bottomAnchor, left: hostProfileImageView.leftAnchor)
        infoLabel.anchor(top: placeStackView.bottomAnchor,
                         right: rightAnchor,
                         paddingRight: 16)
        attendButton.anchor(top: infoLabel.bottomAnchor, paddingTop: 16)
        attendButton.setDimensions(height: 50, width: UIScreen.width)
        attendButton.centerX(inView: self)
        publicCommentLabel.anchor(top: attendButton.bottomAnchor,
                                  left: leftAnchor,
                                  bottom: bottomAnchor,
                                  paddingTop: 16,
                                  paddingLeft: 8,
                                  paddingBottom: 8)
    }
    
    // MARK: - Action
    
    @objc func handleAttendTapped() {
        delegate?.didTapAttendButton(self)
    }

}
