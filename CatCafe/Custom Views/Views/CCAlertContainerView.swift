//
//  CCAlertContainerView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/20.
//

import UIKit

class CCAlertContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
