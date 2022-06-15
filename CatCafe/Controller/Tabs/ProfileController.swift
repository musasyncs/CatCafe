//
//  ProfileController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

private let cellIdentifier = "ProfileCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    private var user: User
    
    // MARK: - Initializer
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
        setupCollectionView()
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    
    func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrowshape.turn.up.left.fill")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleLogout)
        )
    }
    
    func setupCollectionView() {
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        collectionView.backgroundColor = .white
    }
    
    // MARK: - Action
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            let controller = LoginController()
            
            controller.delegate = self.tabBarController as? MainTabController
            
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("DEBUG: Failed to signout")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath) as? ProfileCell
        else { return UICollectionViewCell() }
        
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: headerIdentifier,
            for: indexPath
        ) as? ProfileHeader else { return UICollectionReusableView() }
        
        header.viewModel = ProfileHeaderViewModel(user: user)
        
        return header
    }
    
}

// MARK: - UICollectionViewDelegate
extension ProfileController {
    
}

// MARK: - UICollectionViewFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width =  (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}
