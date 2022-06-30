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
    
    var circleMasked: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(
            origin: CGPoint(
                x: isLandscape ? floor((size.width - size.height) / 2) : 0,
                y: isPortrait ? floor((size.height - size.width) / 2) : 0),
            size: breadthSize)
        )
        else { return nil }
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
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
