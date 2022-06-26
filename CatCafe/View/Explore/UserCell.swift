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
            profileImageView.sd_setImage(with: viewModel.profileImageUrl)
            usernameLabel.text = viewModel.username
            fullnameLabel.text = viewModel.fullname
        }
    }
        
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.image = UIImage(named: "riho")
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "riho123"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "Riho Yoshioka"
        label.textColor = .lightGray
        return label
    }()
    
    lazy var stack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
            
        addSubview(profileImageView)
        addSubview(stack)
        
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
