//
//  Factory.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

// MARK: - UITextView

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
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 7)
            }
        }
    }
    
    private let placeholderLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.notoMedium(size: 12)
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
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

// MARK: - UILabel

func makeLabel(withTitle title: String) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = title
    label.textAlignment = .center
    label.textColor = .black
    label.numberOfLines = 0
    label.adjustsFontSizeToFitWidth = true
    return label
}

// MARK: - UIStackView

func makeStackView(axis: NSLayoutConstraint.Axis) -> UIStackView {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = axis
    stack.spacing = 8.0
    return stack
}

// MARK: - Buttons

func makeAttriTitleButton(text: String, font: UIFont, fgColor: UIColor, kern: Double) -> UIButton {
    let button = UIButton(type: .custom)
    let attributedText = NSMutableAttributedString(string: text, attributes: [
        .font: font,
        .foregroundColor: fgColor,
        .kern: kern
    ])
    button.setAttributedTitle(attributedText, for: .normal)
    return button
}

func makeIconButton(imagename: String,
                    imageColor: UIColor,
                    imageWidth: Int,
                    imageHeight: Int,
                    borderWith: CGFloat? = nil,
                    borderColor: UIColor? = nil,
                    backgroundColor: UIColor? = nil) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let image = UIImage(named: imagename)?
        .withTintColor(imageColor)
        .resize(to: .init(width: imageWidth, height: imageHeight))
    button.setImage(image, for: .normal)
    
    button.backgroundColor = backgroundColor
    
    if let borderWith = borderWith {
        button.layer.borderWidth = borderWith
    }
    button.layer.borderColor = borderColor?.cgColor
    return button
}

func makeTabButton(imageName: String, unselectedImageName: String) -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: imageName), for: .selected)
    button.setImage(UIImage(named: unselectedImageName), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    return button
}
