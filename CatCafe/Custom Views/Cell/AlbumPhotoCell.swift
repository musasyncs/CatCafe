//
//  AlbumPhotoCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/28.
//

import UIKit

class AlbumPhotoCell: UICollectionViewCell {
    
    var assetIdentifier = ""
    let imageView = UIImageView()
        
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(white: 1, alpha: 0.7): .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
