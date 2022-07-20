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
        
    // MARK: - View
    private let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.width))
    private var gridScrollView: GridScrollView!
    private let postSelectControlView = PostSelectControlView()
    private let albumView = UIView()
    private var albumPhotoViewController: AlbumPhotoViewController?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupTopView()
        setupControlView()
        setupAlbumView()
        requestPhoto()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Helper
    private func requestPhoto() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { [weak self] status in
            guard let self = self else { return }
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
    
    private func loadPhotos() {
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
            DispatchQueue.main.async {
                let controller = AlbumPhotoViewController(dataSource: result)
                controller.didSelectAssetHandler = { [weak self] selectedAsset in
                    guard let self = self else { return }
                    self.loadImageFor(selectedAsset)
                }
                self.addChild(controller)
                controller.didMove(toParent: self)
                self.albumView.addSubview(controller.view)
                controller.view.frame = self.albumView.bounds
                self.albumPhotoViewController = controller
            }
        }
    }
    
    private func loadImageFor(_ asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .default,
                                              options: options
        ) { [weak self] image, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.gridScrollView.image = image
            }
        }
        selectedAsset = asset
    }
    
    // MARK: - Action
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func handleNext() {
        guard let croppedImage = gridScrollView.croppedImage else { return }
        let controller = PostFilterController()
        controller.croppedImage = croppedImage
        navigationController?.pushViewController(controller, animated: false)
    }

}

extension PostSelectController {
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .ccGrey
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.asset(.Icons_24px_Close)?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: SFSymbols.arrow_right?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleNext)
        )
    }
    
    private func setupTopView() {
        view.addSubview(topView)
        topView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: UIScreen.width
        )
        
        gridScrollView = GridScrollView(frame: topView.bounds)
        topView.addSubview(gridScrollView)
    }
    
    private func setupControlView() {
        postSelectControlView.delegate = self
        view.addSubview(postSelectControlView)
        postSelectControlView.anchor(
            top: topView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: 50
        )
    }
    
    private func setupAlbumView() {
        view.addSubview(albumView)
        albumView.anchor(
            top: postSelectControlView.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension PostSelectController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.loadPhotos()
    }
    
}

// MARK: - ControlViewDelegate
extension PostSelectController: PostSelectControlViewDelegate {
    
    func didTapCamera(_ view: PostSelectControlView) {
        let controller = PostCameraController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false)
    }

}
