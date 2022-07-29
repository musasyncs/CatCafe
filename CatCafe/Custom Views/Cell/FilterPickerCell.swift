//
//  FilterPickerCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/25.
//

import UIKit

class FilterPickerCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? titleSelectedColor: titleNormalColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                    self.alpha = 0.96
                    self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                } completion: { _ in
                    self.alpha = 1.0
                    self.transform = .identity
                }
            }
        }
    }
    
    let titleNormalColor = UIColor.gray2
    let titleSelectedColor = UIColor.ccGrey
    
    let titleLabel = UILabel()
    let thumbnailImageView = UIImageView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleNormalColor
        thumbnailImageView.backgroundColor = .gray6
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        contentView.addSubviews(titleLabel, thumbnailImageView)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 30)
        thumbnailImageView.anchor(top: titleLabel.bottomAnchor)
        thumbnailImageView.setDimensions(height: 100, width: 100)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
