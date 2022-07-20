//
//  InputTextView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/20.
//

import UIKit

class InputTextView: UITextView {
    
    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }
    
    var placeholderShouldCenter = true {
        didSet {
            if placeholderShouldCenter {
                placeholderLabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 8)
                placeholderLabel.centerY(inView: self)
            } else {
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 8)
            }
        }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .ccGreyVariant
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = .white
        tintColor = .ccGreyVariant
        textColor = .ccGrey
        font = .systemFont(ofSize: 14, weight: .regular)
        isScrollEnabled = false
        textContainerInset = .init(top: 12, left: 2, bottom: 12, right: 2)
        
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextDidChange),
            name: UITextView.textDidChangeNotification, object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTextDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
