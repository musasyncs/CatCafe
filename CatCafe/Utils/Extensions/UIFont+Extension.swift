//
//  UIFont+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

extension UIFont {
    func bold() -> UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
    }
    func italic() -> UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitItalic)!, size: 0)
    }
}

extension UIFont {
    static func notoMedium(size: CGFloat) -> UIFont? {
        var descriptor = UIFontDescriptor(name: CCFontName.regular.rawValue, size: size)
        descriptor = descriptor.addingAttributes(
            [UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium]]
        )
        return UIFont(descriptor: descriptor, size: size)
    }

    static func notoRegular(size: CGFloat) -> UIFont? {
        return UIFont(name: CCFontName.regular.rawValue, size: size)
    }

}
private enum CCFontName: String {
    case regular = "NotoSansCJKtc-Regular"
}
