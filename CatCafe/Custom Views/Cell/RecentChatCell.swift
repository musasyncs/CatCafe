//
//  ChatlistCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/28.
//

import UIKit

class RecentChatCell: UITableViewCell {
    
    var recent: RecentChat? {
        didSet {
            guard let recent = recent else { return }
            
            usernameLabel.text = recent.receiverName
            usernameLabel.adjustsFontSizeToFitWidth = true
            usernameLabel.minimumScaleFactor = 0.9
            
            lastMessageLabel.text = recent.lastMessage
            lastMessageLabel.adjustsFontSizeToFitWidth = true
            lastMessageLabel.numberOfLines = 2
            lastMessageLabel.minimumScaleFactor = 0.9
            
            if recent.unreadCounter != 0 {
                self.unreadCounterLabel.text = "\(recent.unreadCounter)"
                self.unreadCounterBackgroundView.isHidden = false
            } else {
                self.unreadCounterBackgroundView.isHidden = true
            }
                    
            avatarImageView.loadImage(recent.avatarLink)
            
            dateLabel.text = timeElapsed(recent.date ?? Date())
            dateLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    // MARK: - View
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.asset(.no_image)
        imageView.layer.cornerRadius = 50 / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray6
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .ccGrey
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .darkGray
        return label
    }()
    
    private let unreadCounterBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccPrimary
        view.layer.cornerRadius = 28 / 2
        return view
    }()
    
    private let unreadCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout() {
        addSubviews(avatarImageView, usernameLabel, lastMessageLabel, dateLabel, unreadCounterBackgroundView)
        unreadCounterBackgroundView.addSubview(unreadCounterLabel)
        
        avatarImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 10)
        avatarImageView.setDimensions(height: 50, width: 50)
        
        usernameLabel.anchor(
            top: avatarImageView.topAnchor,
            left: avatarImageView.rightAnchor,
            paddingTop: 4,
            paddingLeft: 10
        )
        usernameLabel.setWidth(200)
        
        lastMessageLabel.anchor(
            top: usernameLabel.bottomAnchor,
            left: avatarImageView.rightAnchor,
            paddingTop: 4, paddingLeft: 10
        )
        lastMessageLabel.setWidth(250)
        
        dateLabel.anchor(
            top: topAnchor,
            right: rightAnchor,
            paddingTop: 20,
            paddingRight: 15
        )
        
        unreadCounterBackgroundView.anchor(
            bottom: bottomAnchor,
            right: rightAnchor,
            paddingBottom: 8,
            paddingRight: 16
        )
        unreadCounterBackgroundView.setDimensions(height: 28, width: 28)
        unreadCounterBackgroundView.centerX(inView: unreadCounterBackgroundView)
        
        unreadCounterLabel.center(inView: unreadCounterBackgroundView)
    }
    
    // MARK: - Helper
    func timeElapsed(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        var elapsed = ""
        
        if seconds < 60 {
            elapsed = "Just now"
        } else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            let minText = minutes > 1 ? "mins" : "min"
            elapsed = "\(minutes) \(minText)"
        } else if seconds < 24 * 60 * 60 {
            let hours = Int(seconds / (60 * 60))
            let hourText = hours > 1 ? "hours" : "hour"
            elapsed = "\(hours) \(hourText)"
        } else {
            elapsed = date.longDate()
        }
        
        return elapsed
    }

}
