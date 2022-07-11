//
//  UserCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/15.
//

import UIKit

final class UserCell: UITableViewCell {
    
    var viewModel: UserCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            profileImageView.loadImage(viewModel.profileImageUrl, placeHolder: UIImage.asset(.avatar))
            usernameLabel.text = viewModel.username
            fullnameLabel.text = viewModel.fullname
        }
    }
        
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.asset(.no_image)
        imageView.layer.cornerRadius = 48 / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .ccGrey
        return label
    }()
    
    private let fullnameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var stack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
            
        addSubview(profileImageView)
        addSubview(stack)
        
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
