//
//  UIColor+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

extension UIColor {
    
    static let ccBackground = UIColor.rgb(hex: "#E5E5E5")
    static let ccGrey = UIColor.rgb(hex: "#262628")
    static let ccGreyVariant = UIColor.rgb(hex: "#9797BD")
    static let ccPrimary = UIColor.rgb(hex: "#43A2FA")
    static let ccRed = UIColor.rgb(hex: "#FD1D1D")
    static let ccSecondary = UIColor.rgb(hex: "#E1306C")
    
    static let gray2 = UIColor.rgb(red: 174, green: 174, blue: 178)
    static let gray3 = UIColor.rgb(red: 199, green: 199, blue: 204)
    static let gray4 = UIColor.rgb(red: 209, green: 209, blue: 214)
    static let gray5 = UIColor.rgb(red: 229, green: 229, blue: 234)
    static let gray6 = UIColor.rgb(red: 242, green: 242, blue: 247)

    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return .init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }

    static func rgb(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var hexFormatted = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        return .init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0

        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    static let bronze = CCColor(.bronze)
    private static func CCColor(_ color: CCColor) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
}
private enum CCColor: String {
    case bronze
}
