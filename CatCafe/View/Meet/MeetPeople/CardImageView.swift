//
//  CardImageView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/24.
//

import UIKit

class CardImageView: UIImageView {
    private let gradientLayer = CAGradientLayer()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor     = .darkGray
        layer.cornerRadius  = 10
        contentMode         = .scaleAspectFill
        clipsToBounds       = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.0]
        layer.addSublayer(gradientLayer)
        gradientLayer.frame = self.bounds
    }
}
