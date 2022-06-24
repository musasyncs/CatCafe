//
//  ControlSectionHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit

final class ControlSectionHeader: UITableViewHeaderFooterView {
    
    lazy var galleryButton = makeTitleButton(withText: "圖庫",
                                             font: .systemFont(ofSize: 17, weight: .regular))
    lazy var cameraButton = makeIconButton(imagename: "camera",
                                           imageColor: .white,
                                           imageWidth: 15,
                                           imageHeight: 15,
                                           backgroundColor: .systemGray,
                                           borderColor: .black)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        cameraButton.layer.cornerRadius = 30 / 2

        addSubview(galleryButton)
        addSubview(cameraButton)
        galleryButton.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16, constant: 0)
        cameraButton.centerY(inView: self)
        cameraButton.anchor(right: rightAnchor, paddingRight: 16)
        cameraButton.setDimensions(height: 30, width: 30)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
