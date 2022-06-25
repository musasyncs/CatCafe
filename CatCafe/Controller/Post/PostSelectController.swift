//
//  PostSelectController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit
import Photos

class PostSelectController: UIViewController {
    
    var selectedAsset: PHAsset?
        
    let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.width))
    var gridScrollView: GridScrollView!
    let controlView = ControlView()
    let albumView = UIView()
    var albumPhotoViewController: AlbumPhotoViewController?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        requestPhoto()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    fileprivate func requestPhoto() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    PHPhotoLibrary.shared().register(self)
                    self.loadPhotos()
                }
            case .notDetermined:
                break
            default:
                break
            }
        })
    }
    
    fileprivate func loadPhotos() {
        let options = PHFetchOptions()
        options.wantsIncrementalChangeDetails = false
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        let result = PHAsset.fetchAssets(with: .image, options: options)
        if let firstAsset = result.firstObject {
            loadImageFor(firstAsset)
        }
        
        if let controller = albumPhotoViewController {
            controller.update(dataSource: result)
        } else {
            let controller = AlbumPhotoViewController(dataSource: result)
            controller.didSelectAssetHandler = { [weak self] selectedAsset in
                self?.loadImageFor(selectedAsset)
            }
            
            addChild(controller)
            controller.didMove(toParent: self)
            
            albumView.addSubview(controller.view)
            controller.view.frame = albumView.bounds

            self.albumPhotoViewController = controller
        }
    }
    
    fileprivate func loadImageFor(_ asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .default,
                                              options: options
        ) { (image, _) in
            DispatchQueue.main.async {
                self.gridScrollView.image = image
            }
        }
        selectedAsset = asset
    }
    
    // MARK: - Actions
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func handleNext() {
        let controller = PostFilterController()        
//        controller.croppedImage = scrollView.croppedImage
        navigationController?.pushViewController(controller, animated: false)
    }

}

extension PostSelectController {
    func setup() {
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Icons_24px_Close")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.right")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleNext)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        view.backgroundColor = .white
    }
    
    func layout() {
        controlView.delegate = self
            
        gridScrollView = GridScrollView(frame: topView.bounds)
        topView.addSubview(gridScrollView)
        
        view.addSubview(topView)
        topView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                       left: view.leftAnchor,
                       right: view.rightAnchor,
                       height: UIScreen.width)
        
        view.addSubview(controlView)
        controlView.anchor(top: topView.bottomAnchor,
                           left: view.leftAnchor,
                           right: view.rightAnchor,
                           height: 50)
        
        view.addSubview(albumView)
        albumView.anchor(top: controlView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension PostSelectController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.loadPhotos()
    }
}

// MARK: - ControlViewDelegate
extension PostSelectController: ControlViewDelegate {
    
    func didTapGallery(_ view: ControlView) {
        print("DEBUG: didTapGallery")
    }
    
    func didTapCamera(_ view: ControlView) {
        let controller = PostCameraController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false)
    }

}
