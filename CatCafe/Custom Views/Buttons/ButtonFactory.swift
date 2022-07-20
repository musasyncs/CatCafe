//
//  ButtonFactory.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/20.
//

import UIKit

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
                     foregroundColor: UIColor = UIColor.ccGrey,
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
    
    button.titleLabel?.font = font
            
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
