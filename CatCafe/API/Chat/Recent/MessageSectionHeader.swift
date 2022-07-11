//
//  MessageSectionHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/5.
//

import UIKit

class MessageSectionHeader: UITableViewHeaderFooterView {
    
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let bgView = UIView()
        bgView.backgroundColor = .clear
        backgroundView = bgView
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .ccGrey
        contentView.addSubview(titleLabel)
        titleLabel.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            bottom: contentView.bottomAnchor,
            paddingTop: 4,
            paddingLeft: 16,
            paddingBottom: 4
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
