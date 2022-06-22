//
//  TileView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

class TileView: UIView {
    
    var title: String
    var placeholder: String
    
    let titleLabel = UILabel()
    lazy var textField = CustomTextField(placeholder: placeholder,
                                         textColor: .black,
                                         fgColor: .systemBrown,
                                         font: .notoRegular(size: 11))
    
    init(title: String, placeholder: String) {
        self.title = title
        self.placeholder = placeholder
        super.init(frame: .zero)
        
        // setup
        titleLabel.text = title
        textField.delegate = self
        
        // style
        titleLabel.font = .notoMedium(size: 15)
        titleLabel.textColor = .black
        
        // layout
        addSubview(titleLabel)
        addSubview(textField)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingLeft: 8, height: 36)
        textField.anchor(top: titleLabel.bottomAnchor,
                         left: leftAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         height: 36)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TileView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }
    
}
