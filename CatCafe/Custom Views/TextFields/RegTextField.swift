//
//  RegTextField.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/20.
//

import UIKit

class RegTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        keyboardType = .emailAddress
        autocapitalizationType = .none
        
        borderStyle = .none
        textColor = .white
        font = .systemFont(ofSize: 14, weight: .regular)
        keyboardAppearance = .light
        backgroundColor = .clear
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.ccGreyVariant,
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
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
