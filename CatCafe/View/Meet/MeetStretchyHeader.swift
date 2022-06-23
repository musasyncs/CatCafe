//
//  MeetDetailHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit
import SDWebImage

final class MeetStretchyHeader: UICollectionReusableView {
    
    var imageUrlString: String? {
        didSet {
            guard let imageUrlString = imageUrlString else { return }
            meetImageView.sd_setImage(with: URL(string: imageUrlString))
        }
    }
    
    let meetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "shin")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let gradientView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = .white
        addSubview(meetImageView)
        meetImageView.fillSuperView()
        
        setupGradientView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers

    fileprivate func setupGradientView() {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0.5, 1.2]
        
        gradientView.layer.addSublayer(layer)
        layer.frame = self.bounds
        layer.frame.origin.y -= self.bounds.height
        addSubview(gradientView)
        gradientView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}
