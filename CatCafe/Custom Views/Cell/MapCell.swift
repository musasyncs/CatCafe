//
//  MapCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import UIKit
import MapKit

protocol SearchCellDelegate: AnyObject {
    func focus(forCafe cafe: Cafe)
}

class MapCell: UITableViewCell {
    
    weak var delegate: SearchCellDelegate?
    var finishAnimating = false
    
    var cafe: Cafe? {
        didSet {
            guard let cafe = cafe else { return }
            
            titleLabel.text = cafe.title
            addressLabel.text = cafe.address
            
            if cafe.isSelected {
                animateButtonIn()
            } else {
                goButton.alpha = 0
            }
        }
    }
    
    lazy var goButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitle("Go", for: .normal)
        button.backgroundColor = .ccPrimary
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleZoomIn), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.alpha = 0
        return button
    }()
    
    lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccGreyVariant.withAlphaComponent(0.1)
        view.addSubview(locationImageView)
        locationImageView.center(inView: view)
        locationImageView.setDimensions(height: 16, width: 16)
        return view
    }()
    
    let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.image = UIImage.asset(.pawprint)?
            .resize(to: .init(width: 20, height: 20))?
            .withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .ccGrey
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        
        addSubview(imageContainerView)
        let dimension: CGFloat = 30
        imageContainerView.anchor(left: leftAnchor,
                                  paddingLeft: 12,
                                  width: dimension, height: dimension)
        imageContainerView.layer.cornerRadius = dimension / 2
        imageContainerView.centerY(inView: self)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: imageContainerView.topAnchor,
                          left: imageContainerView.rightAnchor,
                          right: rightAnchor,
                          paddingLeft: 12, paddingRight: 56)
        
        addSubview(addressLabel)
        addressLabel.anchor(top: titleLabel.bottomAnchor,
                            left: imageContainerView.rightAnchor,
                            right: rightAnchor,
                            paddingTop: 4, paddingLeft: 12, paddingRight: 56)
        
        contentView.addSubview(goButton)
        let buttonDimension: CGFloat = 40
        goButton.anchor(right: rightAnchor,
                        paddingRight: 12,
                        width: buttonDimension, height: buttonDimension)
        goButton.centerY(inView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleZoomIn() {
        guard let cafe = cafe else { return }
        delegate?.focus(forCafe: cafe)
    }
    
    // MARK: - Helper Functions
    public func animateButtonIn() {
        goButton.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseInOut) {
                self.goButton.alpha = 1
                self.goButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                self.goButton.transform = .identity
            }
    }
    
}
