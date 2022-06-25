//
//  ControlSectionHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit

protocol ControlSectionHeaderDelegate: AnyObject {
    func didTapGallery(_ header: ControlSectionHeader)
    func didTapCamera(_ header: ControlSectionHeader)
}

final class ControlSectionHeader: UITableViewHeaderFooterView {
    
    weak var delegate: ControlSectionHeaderDelegate?
    
    lazy var galleryButton = makeTitleButton(
        withText: "圖庫",
        font: .systemFont(ofSize: 17, weight: .regular),
        kern: 1,
        foregroundColor: .black
    )
    lazy var cameraButton = makeIconButton(
        imagename: "camera",
        imageColor: .white,
        imageWidth: 15,
        imageHeight: 15,
        backgroundColor: .systemGray,
        borderColor: .black
    )
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        galleryButton.addTarget(self, action: #selector(handleGallery), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
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
    
    // MARK: - Action
    
    @objc func handleGallery() {
        delegate?.didTapGallery(self)
    }
    
    @objc func handleCamera() {
        delegate?.didTapCamera(self)
    }
    
}
