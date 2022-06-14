//
//  UILabel+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

extension UILabel {

    var characterSpacing: CGFloat {
        set {
            if let labelText = text, labelText.count > 0 {
                let attributedString = NSMutableAttributedString(attributedString: attributedText!)
                attributedString.addAttribute(
                    NSAttributedString.Key.kern,
                    value: newValue,
                    range: NSRange(location: 0, length: attributedString.length - 1)
                )
                attributedText = attributedString
            }
        }

        get {
            // swiftlint:disable force_cast
            return attributedText?.value(forKey: NSAttributedString.Key.kern.rawValue) as! CGFloat
            // swiftlint:enable force_cast
        }
    }
}
