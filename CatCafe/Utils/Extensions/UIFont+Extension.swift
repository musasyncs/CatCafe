//
//  UIFont+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

extension UIFont {
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }

}

extension UIFont {
    static func notoRegular(size: CGFloat) -> UIFont {
        return UIFont(name: CCFontName.regular.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
    
    static func notoMedium(size: CGFloat) -> UIFont {
        return UIFont(name: CCFontName.medium.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
    
}
private enum CCFontName: String {
    case regular = "NotoSansCJKtc-Regular"
    case medium = "NotoSansCJKtc-Medium"
}
