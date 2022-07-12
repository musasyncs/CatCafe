//
//  UIButton+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

extension UIButton {
    
    func attributedTitle1(firstPart: String, secondPart: String) {
        
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ccGreyVariant,
            .font: UIFont.systemFont(ofSize: 13)
        ]
        
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: attrs)
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ccPrimary,
            .font: UIFont.boldSystemFont(ofSize: 13)
        ]
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: boldAttrs))
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func attributedTitle2(firstPart: String, secondPart: String) {
        
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.5),
            .font: UIFont.systemFont(ofSize: 11)
        ]
        
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: attrs)
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .font: UIFont.boldSystemFont(ofSize: 11)
        ]
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: boldAttrs))
        setAttributedTitle(attributedTitle, for: .normal)
    }
}
