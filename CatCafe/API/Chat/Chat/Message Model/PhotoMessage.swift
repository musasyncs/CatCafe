//
//  PhotoMessage.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage.asset(.photoPlaceholder)!
        self.size = CGSize(width: 240, height: 240)
    }
    
}
