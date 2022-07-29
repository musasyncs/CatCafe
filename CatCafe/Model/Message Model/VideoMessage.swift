//
//  VideoMessage.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import MessageKit

class VideoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage.asset(.photoPlaceholder)!
        self.size = CGSize(width: 240, height: 240)
    }
    
}
