//
//  PreviewPhotoContainerView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/20.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {

    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage.asset(.cancel_shadow)?
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()

    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage.asset(.save_shadow)?
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        previewImageView.fillSuperView()
        
        cancelButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        cancelButton.setDimensions(height: 50, width: 50)
        
        saveButton.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 24, paddingBottom: 24)
        saveButton.setDimensions(height: 50, width: 50)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    
    @objc func handleSave() {
        print("Handling save...")
        guard let previewImage = previewImageView.image else { return }
        
        let library = PHPhotoLibrary.shared()
        
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }, completionHandler: { _, error in
            if let error = error {
                print("Failed to save image to photo library:", error)
                return
            }
            print("Successfully saved image to library")

            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "保存成功"
                savedLabel.font = .systemFont(ofSize: 18, weight: .medium)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center

                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center

                self.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5,
                               options: .curveEaseOut,
                               animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.5,
                                   options: .curveEaseOut,
                                   animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { _ in
                        savedLabel.removeFromSuperview()
                    })
                })
            }

        })
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }

}
