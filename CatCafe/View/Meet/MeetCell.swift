//
//  MeetCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/22.
//

import UIKit

final class MeetCell: UICollectionViewCell {
    
    //    var viewModel: ? {
    //        didSet {
    //            guard let viewModel = viewModel else { return }
    //
    //        }
    //    }
    
    private let meetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cutecat")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let titleLabel = UILabel()
    
    let timeTitleLabel = UILabel()
    let timeLabel = UILabel()
    lazy var timeStackView = UIStackView(arrangedSubviews: [timeTitleLabel, timeLabel])
    
    let placeTitleLabel = UILabel()
    let placeLabel = UILabel()
    lazy var placeStackView = UIStackView(arrangedSubviews: [placeTitleLabel, placeLabel])
    
    private let hostProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cutecat")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24 / 2
        return imageView
    }()
    let hostnameLabel = UILabel()
    let infoLabel = UILabel()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension MeetCell {
    fileprivate func setup() {
        titleLabel.text = "春Land"
        timeTitleLabel.text = "時間"
        timeLabel.text = "06/25 19:00"
        placeTitleLabel.text = "地點"
        placeLabel.text = "Legacy Taipei"
        hostnameLabel.text = "阿布"
        infoLabel.text = "5人報名 | 1則留言"
    }
    
    fileprivate func style() {
        // style
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
        
        titleLabel.font = .notoMedium(size: 15)
        timeTitleLabel.font = .notoRegular(size: 10)
        timeTitleLabel.textColor = .systemGray
        timeLabel.font = .notoMedium(size: 11)
        placeTitleLabel.font = .notoRegular(size: 10)
        placeTitleLabel.textColor = .systemGray
        placeLabel.font = .notoMedium(size: 11)
        
        timeStackView.axis = .horizontal
        timeStackView.alignment = .center
        timeStackView.spacing = 8
        
        placeStackView.axis = .horizontal
        placeStackView.alignment = .center
        placeStackView.spacing = 8
        
        hostnameLabel.font = .notoRegular(size: 11)
        infoLabel.font = .notoRegular(size: 12)
        infoLabel.textColor = .systemGray
    }
    
    fileprivate func layout() {
        // layout
        [meetImageView,
         titleLabel,
         timeStackView,
         placeStackView,
         hostProfileImageView,
         hostnameLabel,
         infoLabel].forEach {
            addSubview($0)
        }
        
        meetImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        meetImageView.setDimensions(height: 112, width: 112)
        
        titleLabel.anchor(top: meetImageView.topAnchor,
                          left: meetImageView.rightAnchor, paddingLeft: 8)
        timeStackView.anchor(top: titleLabel.bottomAnchor,
                             left: meetImageView.rightAnchor,
                             paddingTop: 8,
                             paddingLeft: 8)
        placeStackView.anchor(top: timeStackView.bottomAnchor,
                              left: meetImageView.rightAnchor,
                              paddingTop: 8,
                              paddingLeft: 8)
        hostProfileImageView.anchor(top: placeStackView.bottomAnchor,
                                    left: placeStackView.leftAnchor,
                                    paddingTop: 8)
        hostProfileImageView.setDimensions(height: 24, width: 24)
        hostnameLabel.centerY(inView: hostProfileImageView,
                              leftAnchor: hostProfileImageView.rightAnchor,
                              paddingLeft: 8)
        infoLabel.anchor(top: hostnameLabel.bottomAnchor, right: rightAnchor, paddingRight: 8)
    }
}
