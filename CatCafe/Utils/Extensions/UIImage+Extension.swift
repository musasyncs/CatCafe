//
//  UIImage+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

extension UIImage {
    
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
    case bookmark_selected
    case bookmark_unselected
    case home_selected
    case home_unselected
    case profile_selected
    case profile_unselected
    case search_selected
    case search_unselected
    case speaker_selected
    case speaker_unselected
    
    case cancel_shadow
    case comment
    case gear
    case grid
    case like_selected
    case like_unselected
    case list
    case play
    case plus_photo
    case plus_unselected
    case ribbon
    case right_arrow_shadow
    case save_shadow
    case send2
    case upload_image_icon
     
}
