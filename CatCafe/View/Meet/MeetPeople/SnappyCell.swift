//
//  SnappyCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/24.
//

import UIKit

protocol SnappyCellDelegate: AnyObject {
    func presentInfoView(withPerson person: Person)
}

class SnappyCell: UICollectionViewCell {
    
    weak var delegate: SnappyCellDelegate?

    var person: Person? {
        didSet {
            guard let person = person else { return }
            
            UserService.fetchUserBy(uid: person.uid) { user in
                guard let url = URL(string: user.profileImageUrlString) else { return }
                self.superImageView.sd_setImage(with: url)
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            let timeText = formatter.string(from: person.timestamp.dateValue())
            timeLabel.text = "報名日期：\(timeText)"
        }
    }

    let timeLabel = UILabel()
    lazy var superImageView = CardImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressGestureRecognizer)
        
        // style
        backgroundColor = .clear
        
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 16
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.init(white: 1, alpha: 0.5).cgColor
        
        superImageView.layer.cornerRadius = 16
        superImageView.layer.masksToBounds = true

        timeLabel.textColor = .white
        timeLabel.font = .notoRegular(size: 10)
        
        // layout
        contentView.addSubview(superImageView)
        contentView.addSubview(timeLabel)
            
        superImageView.fillSuperView()
        timeLabel.anchor(left: contentView.leftAnchor,
                         bottom: contentView.bottomAnchor,
                         paddingLeft: 12,
                         paddingBottom: 12)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            guard let person = self.person else { return }
            delegate?.presentInfoView(withPerson: person)
        }
    }
    
}
