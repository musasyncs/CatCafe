//
//  CustomTextField.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import UIKit

class CustomTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    init(placeholder: String, textColor: UIColor, fgColor: UIColor, font: UIFont) {
        super.init(frame: .zero)
        
        self.textColor = textColor
        self.font = .systemFont(ofSize: 11, weight: .regular)
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: fgColor,
                NSAttributedString.Key.font: font
            ]
        )
        
        // Add Under Line
        let underline = UIView()
        addSubview(underline)
        underline.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 0.5)
        underline.backgroundColor = .ccGrey
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
