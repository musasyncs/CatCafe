//
//  TileView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

protocol TileViewDelegate: AnyObject {
    func tileView(_ tileView: TileView, wantsToScrollToTextField textField: UITextField)
    func scrollToOriginalPlace()
}

class TileView: UIView {
    
    weak var delegate: TileViewDelegate?
    
    var title: String
    var placeholder: String
    
    let titleLabel = UILabel()
    lazy var textField = CustomTextField(
        placeholder: placeholder,
        textColor: .ccGrey,
        fgColor: .ccPrimary,
        font: .systemFont(ofSize: 12, weight: .regular)
    )
    
    init(title: String, placeholder: String) {
        self.title = title
        self.placeholder = placeholder
        super.init(frame: .zero)
        
        // setup
        titleLabel.text = title
        textField.delegate = self
        
        // style
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .ccGrey
        textField.returnKeyType = .done
        
        // layout
        addSubview(titleLabel)
        addSubview(textField)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingLeft: 8, height: 36)
        textField.anchor(
            top: titleLabel.bottomAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            height: 36
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TileView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 2 {
            delegate?.scrollToOriginalPlace()
        }
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if textField.tag == 1 {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            delegate?.tileView(self, wantsToScrollToTextField: textField)
        }
    }
    
}
