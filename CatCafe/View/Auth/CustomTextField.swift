//
//  CustomTextField.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

final class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        borderStyle = .none
        textColor = .black
        keyboardAppearance = .light
        keyboardType = .emailAddress
        backgroundColor = UIColor.systemGray6
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray]
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
 
