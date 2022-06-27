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
            .withTintColor(.systemBrown)
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
        dividerView.backgroundColor = .black
        addSubview(dividerView)
        dividerView.anchor(left: leftAnchor,
                           bottom: bottomAnchor,
                           right: rightAnchor,
                           paddingLeft: 8, paddingRight: 8,
                           height: 0.6)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class RegTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        keyboardType = .emailAddress
        autocapitalizationType = .none
        
        borderStyle = .none
        textColor = .black
        font = .systemFont(ofSize: 13, weight: .regular)
        keyboardAppearance = .light
        backgroundColor = .clear
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 13, weight: .regular)
            ]
        )
        
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        leftView = spacer
        leftViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
