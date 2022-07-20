//
//  SnappyFlowLayout.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/24.
//

import UIKit

class SnappyFlowLayout: UICollectionViewFlowLayout {
    
    let activeDistance: CGFloat = 200
    let zoomFactor: CGFloat = 0.3
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        scrollDirection = .horizontal
        minimumLineSpacing = 65
    }
    
    private func getCollectionView() -> UICollectionView {
        guard let collectionView = collectionView else {
            fatalError("Collection View is not present")
        }
        return collectionView
    }
    
    // swiftlint:disable all
    override func prepare() {
        let collectionView = getCollectionView()
        let width = collectionView.frame.width * 0.5
        let height = collectionView.frame.height * 0.5
        itemSize = CGSize(width: width, height: height)
        
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let collectionView = getCollectionView()
        
        let rectAttrs = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes
        }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        
        for attrs in rectAttrs where attrs.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attrs.center.x
            let normalizeDistance = distance / activeDistance
            
            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizeDistance.magnitude)
                attrs.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attrs.zIndex = Int(zoom.rounded())
            }
        }
        return rectAttrs
    }
    // swiftlint:ensable all
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let collectionView = getCollectionView()
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        
        guard let rectAttrs = super.layoutAttributesForElements(in: targetRect) else {
            return .zero
        }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
        
        for layoutAttributes in rectAttrs {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let collectionView = getCollectionView()
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView.bounds.size
        return context
    }
}
