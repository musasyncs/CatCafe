//
//  PostSelectController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit
import Photos

class PostSelectController: UIViewController {
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    var selectedImage: UIImage? {
        didSet {
            DispatchQueue.main.async {
                guard let selectedImage = self.selectedImage else { return }
                
                if let index = self.images.firstIndex(of: selectedImage) {
                    
                    let imageManager = PHImageManager.default()
                    let selectedAsset = self.assets[index]
                    
                    imageManager.requestImage(for: selectedAsset,
                                                 targetSize: CGSize(width: 600, height: 600),
                                                 contentMode: .default,
                                                 options: nil
                    ) { (image, _) in
                        self.topHeaderView.photoImageView.image = image
                    }
                }
                
            }
        }
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let topHeaderView = TopTableHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.width))
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationButtons()
        setupTableView()
        fetchPhotos()
    }
    
    // MARK: - Helpers

    func setupNavigationButtons() {
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
    }
    
    func setupTableView() {
        tableView.tableHeaderView = topHeaderView
        
        tableView.register(PhotoWallTableViewCell.self,
                           forCellReuseIdentifier: PhotoWallTableViewCell.identifier)
        tableView.register(ControlSectionHeader.self,
                           forHeaderFooterViewReuseIdentifier: ControlSectionHeader.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
    
    func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            
            allPhotos.enumerateObjects { (asset, count, _) in
                
                let phImageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                
                options.isSynchronous = true
                
                phImageManager.requestImage(for: asset,
                                               targetSize: targetSize,
                                               contentMode: .aspectFit,
                                               options: options,
                                               resultHandler: { (image, _) in
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)

                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    fileprivate func assetFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    // MARK: - Actions

    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func handleNext() {
//        let postEditController = PostEditController()
//        postEditController.selectedImage = header?.photoImageView.image
//        navigationController?.pushViewController(postEditController, animated: true)
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension PostSelectController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PhotoWallTableViewCell.identifier,
            for: indexPath) as? PhotoWallTableViewCell
        else { return UITableViewCell() }
        
        cell.delegate = self
        cell.images = self.images
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // table view section header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let controlHeader = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ControlSectionHeader.identifier) as? ControlSectionHeader
        else { return UIView() }
        return controlHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

// MARK: - PhotoWallTableViewCellDelegate

extension PostSelectController: PhotoWallTableViewCellDelegate {
    
    func didTapItem(_ cell: PhotoWallTableViewCell, with selectedImage: UIImage) {
        self.selectedImage = selectedImage
    }
    
}
