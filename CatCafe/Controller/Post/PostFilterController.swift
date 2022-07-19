//
//  PostFilterController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/25.
//

import UIKit
import Photos
import MetalPetal

class PostFilterController: UIViewController {
    
    public var croppedImage: UIImage!
    
    private var allFilters: [MTFilter.Type] = []
    private var originInputImage: MTIImage?
    private var thumbnails: [String: UIImage] = [:]
    private var currentSelectFilterIndex: Int = 0
    private var currentAdjustStrengthFilter: MTFilter?
    
    // MARK: - View
    private let previewView = UIView()
    private let filtersView = UIView()
    private var collectionView: UICollectionView!
    private var filterControlView: FilterControlView?
    private var mtImageView: MTIImageView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        allFilters = MTFilterManager.shared.allFilters
        
        view.backgroundColor = .white
        setupNavigationButton()
        setupCollectionView()
        setupMtImageView()
        setupLayout()
        generateFilterThumbnails()
    }
    
    // MARK: - Helper
    private func presentFilterControlView(for tool: FilterToolItem) {
        let width = filtersView.bounds.width
        let height = filtersView.bounds.height + 44 + view.safeAreaInsets.bottom
        let frame = CGRect(x: 0, y: view.bounds.height - height + 44, width: width, height: height)
        
        let value = valueForFilterControlView(with: tool)
        let controlView = FilterControlView(frame: frame, filterTool: tool, value: value)
        controlView.delegate = self
        filterControlView = controlView
        
        UIView.animate(withDuration: 0.2) {
            self.view.addSubview(controlView)
            controlView.setPosition(offScreen: false)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.title = tool.title
            self.clearNavigationButton()
        }
    }
    
    private func valueForFilterControlView(with tool: FilterToolItem) -> Float {
        switch tool.type {
        case .adjustStrength:
            return 1.0
        }
    }
    
    private func dismissFilterControlView() {
        UIView.animate(withDuration: 0.2) {
            self.filterControlView?.setPosition(offScreen: true)
        } completion: { [ weak self] _ in
            guard let self = self else { return }
            self.filterControlView?.removeFromSuperview()
            self.title = ""
            self.setupNavigationButton()
        }
    }
    
    // MARK: - Action
    @objc func cancelBarButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc func nextBarButtonTapped() {
        guard let image = self.mtImageView.image,
              let uiImage = MTFilterManager.shared.generate(image: image) else { return }
        let postEditController = PostEditController()
        postEditController.image = uiImage
        self.navigationController?.pushViewController(postEditController, animated: false)
    }
    
}

extension PostFilterController {
    
    private func setupNavigationButton() {
        let leftBarButton = UIBarButtonItem(
            image: UIImage.asset(.Icons_24px_Back02)?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(cancelBarButtonTapped)
        )
        let rightBarButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.right")?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(nextBarButtonTapped)
        )
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func clearNavigationButton() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = nil
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: 104, height: 134)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        filtersView.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FilterPickerCell.self, forCellWithReuseIdentifier: FilterPickerCell.identifier)
        collectionView.reloadData()
    }
    
    private func setupMtImageView() {
        mtImageView = MTIImageView(frame: .zero)
        mtImageView.resizingMode = .aspectFill
        mtImageView.backgroundColor = .lightGray
        let ciImage = CIImage(cgImage: croppedImage.cgImage!)
        let originImage = MTIImage(ciImage: ciImage, isOpaque: true)
        originInputImage = originImage
        mtImageView.image = originImage
    }
    
    private func setupLayout() {
        view.addSubview(previewView)
        previewView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: UIScreen.width
        )
        
        previewView.addSubview(mtImageView)
        mtImageView.fillSuperView()
        
        view.addSubview(filtersView)
        filtersView.anchor(
            top: previewView.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingBottom: 44
        )
        
        filtersView.addSubview(collectionView)
        collectionView.centerY(inView: filtersView)
        collectionView.setDimensions(height: 154, width: UIScreen.width)
    }
    
    private func generateFilterThumbnails() {
        DispatchQueue.global().async {
            let size = CGSize(width: 200, height: 200)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            self.croppedImage.draw(in: CGRect(origin: .zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            if let image = scaledImage {
                for filter in self.allFilters {
                    let image = MTFilterManager.shared.generateThumbnailsForImage(image, with: filter)
                    self.thumbnails[filter.name] = image
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

}

// MARK: - FilterControlViewDelegate
extension PostFilterController: FilterControlViewDelegate {
    
    func filterControlViewDidPressCancel() {
        // dicard filter
        currentAdjustStrengthFilter?.strength = 0
        mtImageView.image = currentAdjustStrengthFilter?.outputImage
        // dismiss
        dismissFilterControlView()
    }
    
    func filterControlViewDidPressDone() {
        dismissFilterControlView()
    }
    
    func filterControlView(
        _ controlView: FilterControlView,
        didChangeValue value: Float,
        filterTool: FilterToolItem
    ) {
        if filterTool.type == .adjustStrength {
            currentAdjustStrengthFilter?.strength = value
            mtImageView.image = currentAdjustStrengthFilter?.outputImage
            return
        }
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PostFilterController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allFilters.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilterPickerCell.identifier,
            for: indexPath
        ) as? FilterPickerCell else { return UICollectionViewCell() }
        
        let filter = allFilters[indexPath.item]
        cell.update(filter)
        cell.thumbnailImageView.image = thumbnails[filter.name]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // double tap
        if currentSelectFilterIndex == indexPath.item {
            if indexPath.item != 0 {
                let item = FilterToolItem(type: .adjustStrength, slider: .zeroToHundred)
                presentFilterControlView(for: item)
                currentAdjustStrengthFilter = allFilters[currentSelectFilterIndex].init()
                currentAdjustStrengthFilter?.inputImage = originInputImage
            }
        } else {
            let filter = allFilters[indexPath.item].init()
            filter.inputImage = originInputImage
            mtImageView.image = filter.outputImage
            currentSelectFilterIndex = indexPath.item
        }
    }

}
