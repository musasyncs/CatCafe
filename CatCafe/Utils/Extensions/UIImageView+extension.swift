//
//  KingFisherWrapper.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {
        guard urlString != nil else { return }
        let url = URL(string: urlString!)
        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}
