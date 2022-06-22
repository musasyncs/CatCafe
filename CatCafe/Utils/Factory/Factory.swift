//
//  Factory.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

// MARK: - Custom Text Fields

class MeetArrangeTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        textColor = .black
        font = .notoRegular(size: 11)
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.systemBrown,
                NSAttributedString.Key.font: UIFont.notoRegular(size: 11)
            ]
        )
        
        // Add Under Line
        let underline = UIView()
        addSubview(underline)
        underline.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 0.5)
        underline.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
    
    let placeholderLabel: UILabel = {
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

func makeIconButton(imagename: String,
                    imageColor: UIColor,
                    imageWidth: Int,
                    imageHeight: Int,
                    backgroundColor: UIColor = .white,
                    cornerRadius: CGFloat = 0,
                    borderWith: CGFloat = 0,
                    borderColor: UIColor = .clear) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let image = UIImage(named: imagename)?
        .withTintColor(imageColor)
        .resize(to: .init(width: imageWidth, height: imageHeight))
    button.setImage(image, for: .normal)
    
    button.backgroundColor = backgroundColor
    button.layer.cornerRadius = cornerRadius
    button.layer.borderWidth = borderWith
    button.layer.borderColor = borderColor.cgColor
    return button
}

func makeTitleButton(withText text: String,
                     font: UIFont,
                     kern: Double = 1,
                     foregroundColor: UIColor = .black,
                     backgroundColor: UIColor = .clear,
                     insets: UIEdgeInsets = .zero,
                     cornerRadius: CGFloat = 0,
                     borderWidth: CGFloat = 0,
                     borderColor: UIColor = .clear) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let attributedText = NSMutableAttributedString(
        string: text,
        attributes: [
            .font: font,
            .foregroundColor: foregroundColor,
            .kern: kern
        ])
    button.setAttributedTitle(attributedText, for: .normal)
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    
    button.contentEdgeInsets = insets
    button.layer.cornerRadius = cornerRadius
    button.layer.borderWidth = borderWidth
    button.layer.borderColor = borderColor.cgColor
    button.backgroundColor = backgroundColor
    return button
}

func makeTabButton(imageName: String, unselectedImageName: String) -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: imageName), for: .selected)
    button.setImage(UIImage(named: unselectedImageName), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    return button
}
