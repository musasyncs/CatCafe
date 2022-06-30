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
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
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

func makeBarButtonItem(target: Any?,
                       foregroundColor: UIColor,
                       text: String,
                       traits: UIFontDescriptor.SymbolicTraits,
                       insets: UIEdgeInsets = .zero,
                       selector: Selector
) -> UIBarButtonItem {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(target, action: selector, for: .primaryActionTriggered)
    
    let attributes = [
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1).withTraits(traits: traits),
        NSAttributedString.Key.foregroundColor: foregroundColor
    ]
    let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    button.setAttributedTitle(attributedText, for: .normal)
    
    button.contentEdgeInsets = insets
    let barButtonItem = UIBarButtonItem(customView: button)
    return barButtonItem
}

func makeIconButton(imagename: String,
                    imageColor: UIColor? = nil,
                    imageWidth: Int,
                    imageHeight: Int,
                    backgroundColor: UIColor = .clear,
                    cornerRadius: CGFloat = 0,
                    borderWith: CGFloat = 0,
                    borderColor: UIColor = .clear) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    
    var image = UIImage(named: imagename)?
        .resize(to: .init(width: imageWidth, height: imageHeight))
    
    if let imageColor = imageColor {
        image = image?.withTintColor(imageColor)
    }
    
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
                     borderColor: UIColor = .clear
) -> UIButton {
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
    button.backgroundColor = backgroundColor
    
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    
    button.contentEdgeInsets = insets
    button.layer.cornerRadius = cornerRadius
    button.layer.borderWidth = borderWidth
    button.layer.borderColor = borderColor.cgColor
    return button
}

func makeTabButton(imageName: String, unselectedImageName: String) -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: imageName), for: .selected)
    button.setImage(UIImage(named: unselectedImageName), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    return button
}
