//
//  DropDownCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit

final class DropDownCell: UITableViewCell {
    
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.rgb(hex: "FAFAFA")
        selectionStyle = .none
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor,
                          paddingTop: 8, paddingLeft: 8, paddingBottom: 8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
