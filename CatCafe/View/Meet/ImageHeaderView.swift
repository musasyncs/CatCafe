//
//  ImageHeaderView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

class ImageHeaderView: UIView {
    
    lazy var picView: PicView = {
        let view = PicView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picView)
        picView.centerX(inView: self)
        picView.centerY(inView: self)
        picView.setDimensions(height: 104, width: 104)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class PicView: UIView {
    
    lazy var placedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(placedImageView)
        placedImageView.fillSuperView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
