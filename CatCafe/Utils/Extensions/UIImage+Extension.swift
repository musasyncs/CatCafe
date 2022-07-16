//
//  UIImage+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

extension UIImage {
    
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
    func resize(to goalSize: CGSize) -> UIImage? {
        let widthRatio = goalSize.width / size.width
        let heightRatio = goalSize.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
}

// swiftlint:enable identifier_name
extension UIImage {
    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}

enum ImageAsset: String {
    
    // swiftlint:disable identifier_name
    
    // tabs
    case home_selected
    case home_unselected
    case search_selected
    case search_unselected
    case map_selected
    case map_unselected
    case speaker_selected
    case speaker_unselected
    case profile_selected
    case profile_unselected
    
    // camera
    case camera
    case capture_photo
    case meet_camera
    case save_shadow
    
    // logo
    case logo
    case logo_text
    
    // map
    case catAnno
    case info
    case location_arrow_flat
    case location
    case map
    case pawprint
    case website
    case Icons_24px_RegisterCellphone
    
    // chat
    case chat
    case comment
    case add_icon
    case camera_icon
    case delete_icon
    case picture_icon
    case send_icon
    
    // navigation
    case back
    case cancel_shadow
    case check
    case cross
    case delete
    case right_arrow
    case Icons_24px_Close
    case Icons_24px_Back02
    
    // others
    case heart
    case like_selected
    case like_unselected
    case lock
    case logout
    case mail
    case plus_photo
    case plus_unselected
    case plus
    case trash
    case user
    
    // placeholder
    case no_image
    case photoPlaceholder
    
    // profile
    case profile_back
    
}
