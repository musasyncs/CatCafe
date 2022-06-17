//
//  TopTableViewCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit

final class TopTableHeaderView: UIView {
    
    var image: UIImage? {
        didSet {
            photoImageView.image = image
        }
    }
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.fillSuperView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
