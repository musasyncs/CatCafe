//
//  Factory.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

func makeNavigationController(rootViewController: UIViewController) -> UINavigationController {
    let navController = UINavigationController(rootViewController: rootViewController)
    
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithDefaultBackground()
    navBarAppearance.backgroundColor = .white
    
    // navbar 標題顏色跟字型
    let attrs = [
        NSAttributedString.Key.foregroundColor: UIColor.ccGrey,
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)
    ]
    navBarAppearance.titleTextAttributes = attrs
    
    // navbar 返回按鈕自訂圖片("arrow.backward")
    let backIndicatorImage = UIImage.asset(.Icons_24px_Back02)?
        .withRenderingMode(.alwaysOriginal)
        .withTintColor(.ccGrey)
    navBarAppearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorImage)
    
    // 返回按鈕 字型樣式(clear color)
    let backButtonAppearance = UIBarButtonItemAppearance()
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    navBarAppearance.backButtonAppearance = backButtonAppearance
    
    let controllerName = String(describing: type(of: rootViewController.self))
    
    // Hide navigation bar underline
    [
        String(describing: FeedController.self),
        String(describing: ExploreController.self),
        String(describing: MeetController.self),
        String(describing: ProfileController.self)
        
    ].forEach { name in
        if name == controllerName {
            navBarAppearance.shadowColor = .clear
        }
    }
    
    // Status bar style
    [ String(describing: ProfileController.self)].forEach { name in
        if name == controllerName {
            navController.navigationBar.overrideUserInterfaceStyle = .dark
        } else {
            navController.navigationBar.overrideUserInterfaceStyle = .light
        }
    }
    
    navController.navigationBar.standardAppearance = navBarAppearance
    navController.navigationBar.compactAppearance = navBarAppearance
    navController.navigationBar.scrollEdgeAppearance = navBarAppearance
    return navController
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

// MARK: - UILabel
func makeLabel(withTitle title: String, font: UIFont, textColor: UIColor) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = title
    label.font = font
    label.textAlignment = .left
    label.textColor = textColor
    label.backgroundColor = .clear
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

func makeProfileEditButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "square.and.pencil")?.resize(to: .init(width: 20, height: 20)), for: .normal)
    button.imageView?.contentMode = .scaleToFill
    
    button.layer.cornerRadius = 28/2
    button.layer.borderWidth = 0.3
    button.layer.borderColor = UIColor.darkGray.cgColor
    
    button.backgroundColor = .white
    button.tintColor = .darkGray
    return button
}
