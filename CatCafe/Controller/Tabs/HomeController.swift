//
//  HomeController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "cell"

class HomeController: UICollectionViewController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRightNavItems()
        setupCollectionView()
    }
    
    // MARK: - Helpers
    
    private func setupRightNavItems() {
        
        let chatButton = UIButton(type: .system)
        chatButton.setImage(UIImage(named: "send2")?.withRenderingMode(.alwaysOriginal), for: .normal)
        chatButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        let notificationButton = UIButton(type: .system)
        notificationButton.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        notificationButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        let postButton = UIButton(type: .system)
        postButton.setImage(UIImage(named: "plus_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        postButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: chatButton),
                                              UIBarButtonItem(customView: notificationButton),
                                              UIBarButtonItem(customView: postButton)]
    }
    
    func setupCollectionView() {
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
    }
    
    // MARK: - Actions
    
}

// MARK: - UICollectionViewDataSource

extension HomeController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath) as? FeedCell
        else { return UICollectionViewCell() }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        return CGSize(width: view.frame.width, height: height)
    }
}
