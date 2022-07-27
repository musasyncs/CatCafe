//
//  UIHelper.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/24.
//

import UIKit

enum UIHelper {
    
    static func createBaseMeetChildFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let screenWidth = view.bounds.width
        let minimumItemSpacing: CGFloat = 16
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = minimumItemSpacing
        let itemWidth = screenWidth - 8 * 2
        flowLayout.itemSize = CGSize(width: itemWidth, height: 170)
                
        return flowLayout
    }
    
    static func createExploreFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let screenWidth = view.bounds.width
        let minimumLineSpacing: CGFloat = 5
        let minimumItemSpacing: CGFloat = 5
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = minimumLineSpacing
        flowLayout.minimumInteritemSpacing = minimumItemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        let itemWidth = (screenWidth - 36 - minimumItemSpacing * 2) / 3
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return flowLayout
    }
    
    static func createProfileFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let screenWidth = view.bounds.width
        let minimumLineSpacing: CGFloat = 5
        let minimumItemSpacing: CGFloat = 5
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = minimumLineSpacing
        flowLayout.minimumInteritemSpacing = minimumItemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 18, bottom: 0, right: 18)
        flowLayout.headerReferenceSize = CGSize(width: screenWidth, height: 200)
        
        let itemWidth = (screenWidth - 36 - minimumItemSpacing * 2) / 3
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return flowLayout
    }
    
}
