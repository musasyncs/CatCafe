//
//  PlaceCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import UIKit

class PlaceCell: UITableViewCell {
    
    var viewModel: PlaceCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.attributedText = viewModel.titleAttrString
            addressLabel.attributedText = viewModel.subtitleAttrString
        }
    }
    
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    lazy var stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
            
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
