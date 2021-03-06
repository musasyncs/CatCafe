//
//  AlbumPhotoViewController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/25.
//

import UIKit
import Photos

class AlbumPhotoViewController: UIViewController {

    var didSelectAssetHandler: ((PHAsset) -> Void)?
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var dataSource: PHFetchResult<PHAsset>
    fileprivate var currentSelectIndex: IndexPath?
    fileprivate var targetSize: CGSize = .zero
    
    init(dataSource: PHFetchResult<PHAsset>) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let columns = 4
        let itemWidth: CGFloat = (view.frame.width -  CGFloat(columns + 1))/CGFloat(columns)
        targetSize = CGSize(width: itemWidth * UIScreen.main.scale, height: itemWidth * UIScreen.main.scale)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AlbumPhotoCell.self, forCellWithReuseIdentifier: NSStringFromClass(AlbumPhotoCell.self))
        view.addSubview(collectionView)
        
        collectionView.reloadData()
        if dataSource.count > 0 {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
        }
    }

    public func update(dataSource: PHFetchResult<PHAsset>) {
        DispatchQueue.main.async {
            self.dataSource = dataSource
            self.collectionView.reloadData()
        }
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AlbumPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
            let identifier = NSStringFromClass(AlbumPhotoCell.self)
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? AlbumPhotoCell else { return UICollectionViewCell() }
        
        let asset = dataSource.object(at: indexPath.row)
        cell.assetIdentifier = asset.localIdentifier
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit,
                                              options: option
        ) { [unowned cell] (image, _) in
            DispatchQueue.main.async {
                if asset.localIdentifier == cell.assetIdentifier {
                    cell.imageView.image = image
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentSelectIndex == indexPath {
            return
        }
        currentSelectIndex = indexPath
        let asset = dataSource.object(at: indexPath.item)
        didSelectAssetHandler?(asset)
    }
}

class AlbumPhotoCell: UICollectionViewCell {
    
    let imageView: UIImageView
    
    var assetIdentifier: String = ""
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(white: 1, alpha: 0.7): .clear
        }
    }
    
    override init(frame: CGRect) {
        
        imageView = UIImageView(frame: CGRect(origin: .zero, size: frame.size))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        
        super.init(frame: frame)
        
        backgroundView = imageView
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
