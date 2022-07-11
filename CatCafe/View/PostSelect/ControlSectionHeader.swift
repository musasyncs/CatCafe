//
//  ControlSectionHeader.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit

protocol ControlViewDelegate: AnyObject {
    func didTapCamera(_ view: ControlView)
}

final class ControlView: UIView {
    
    weak var delegate: ControlViewDelegate?
    
    lazy var galleryButton = makeTitleButton(
        withText: "圖庫",
        font: .systemFont(ofSize: 17, weight: .regular),
        kern: 1,
        foregroundColor: .ccGrey
    )
    lazy var cameraButton = makeIconButton(
        imagename: ImageAsset.camera.rawValue,
        imageColor: .white,
        imageWidth: 15,
        imageHeight: 15,
        backgroundColor: .systemGray,
        borderColor: .ccGrey
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    @objc func handleCamera() {
        delegate?.didTapCamera(self)
    }
    
}
