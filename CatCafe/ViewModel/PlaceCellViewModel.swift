//
//  PlaceCellViewModel.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import UIKit

struct PlaceCellViewModel {
    
    var cafe: Cafe
    
    var titleAttrString: NSAttributedString {
        let attributedText = NSAttributedString(
            string: cafe.title,
            attributes: [
                .foregroundColor: UIColor.ccGrey,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium) as Any
            ]
        )
        return attributedText
    }
    
    var subtitleAttrString: NSAttributedString {
        let attrText = NSAttributedString(
            string: cafe.address,
            attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium) as Any
            ]
        )
        return attrText
    }
    
    init(cafe: Cafe) {
        self.cafe = cafe
    }
}
