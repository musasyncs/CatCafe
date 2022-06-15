//
//  Factory.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

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
                    borderWith: CGFloat? = nil,
                    borderColor: UIColor? = nil) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let image = UIImage(named: imagename)?.withTintColor(imageColor).resize(to: .init(width: 24, height: 24))
    button.setImage(image, for: .normal)
    
    button.backgroundColor = .white
    
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
