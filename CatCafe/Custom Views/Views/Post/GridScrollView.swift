//
//  GridScrollView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit

class GridScrollView: UIScrollView {
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.frame.size = actualSizeFor(image)
                contentSize = imageView.bounds.size
                
                let offset = CGPoint(
                    x: (contentSize.width - bounds.width) / 2,
                    y: (contentSize.height - bounds.height) / 2
                )
                setContentOffset(offset, animated: false)
            }
        }
    }
    
    var croppedImage: UIImage? {
        guard let image = image else { return nil }
        
        let scaleX = image.size.width / contentSize.width
        let scaleY = image.size.height / contentSize.height
        
        var cropRect = CGRect.zero
        cropRect.origin.x = contentOffset.x * scaleX
        cropRect.origin.y = contentOffset.y * scaleY
        cropRect.size.width = image.size.width * bounds.width / contentSize.width
        cropRect.size.height = image.size.height * bounds.height / contentSize.height
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    // MARK: - View
    private let imageView = UIImageView()
    private lazy var gridView = GridView(frame: bounds)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delaysContentTouches = false
        zoomScale = 1.0
        minimumZoomScale = 1.0
        maximumZoomScale = 5.0
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        recognizer.delegate = self
        recognizer.minimumPressDuration = 0
        addGestureRecognizer(recognizer)
        
        gridView.isUserInteractionEnabled = false
        gridView.alpha = 0.0
        
        addSubview(imageView)
        addSubview(gridView)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    func actualSizeFor(_ image: UIImage) -> CGSize {
        let viewSize = bounds.size
        
        var actualWidth = image.size.width
        var actualHeight = image.size.height
        var imgRatio = actualWidth/actualHeight
        let viewRatio = viewSize.width/viewSize.height
        
        if imgRatio != viewRatio {
            if imgRatio > viewRatio {
                imgRatio = viewSize.height / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = viewSize.height
            } else {
                imgRatio = viewSize.width / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = viewSize.width
            }
        } else {
            imgRatio = viewSize.width / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = viewSize.width
        }
        
        return CGSize(width: actualWidth, height: actualHeight)
    }
    
    // MARK: - Action
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.2) {
                self.gridView.alpha = 1.0
            }
        case .ended:
            UIView.animate(withDuration: 0.2) {
                self.gridView.alpha = 0.0
            }
        default:
            break
        }
    }
    
}

extension GridScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gridView.frame = bounds
    }
    
}

extension GridScrollView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
    
}
