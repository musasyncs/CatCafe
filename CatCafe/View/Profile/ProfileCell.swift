//
//  ProfileCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    private let postImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "cutecat")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
