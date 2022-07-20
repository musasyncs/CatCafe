//
//  InputContainerView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import UIKit

class InputContainerView: UIView {
    
    init(imageName: String, textField: UITextField) {
        super.init(frame: .zero)
    
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.ccGreyVariant)
        imageView.alpha = 0.87
        imageView.contentMode = .scaleAspectFit
        
        setHeight(36)
        
        addSubview(imageView)
        imageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        imageView.setDimensions(height: 16, width: 16)
        
        addSubview(textField)
        textField.centerY(inView: self)
        textField.anchor(left: imageView.rightAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         paddingBottom: -8, paddingRight: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .ccGreyVariant
        addSubview(dividerView)
        dividerView.anchor(left: leftAnchor,
                           bottom: bottomAnchor,
                           right: rightAnchor,
                           paddingLeft: 8, paddingRight: 8,
                           height: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
