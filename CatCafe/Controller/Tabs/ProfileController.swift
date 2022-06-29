//
//  ProfileController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class ProfileController: UICollectionViewController {
    
    private var user: User
    private var posts = [Post]()
    
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
        setupBarButtonItem()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserIsFollowed()
        fetchUserStats()
        fetchUserPosts()
    }
    
    // MARK: - API
    
    func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserPosts() {
        PostService.fetchPosts(forUser: user.uid) { posts in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func setupBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "logout")?
                .resize(to: .init(width: 20, height: 20))?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleLogout)
        )
    }
    
    func setupCollectionView() {
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeader.identifier)
        collectionView.backgroundColor = .white
        
        // setup pull to refresh
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    // MARK: - Action
    @objc func handleLogout() {
        let alert = UIAlertController(title: "是否登出？", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            
            self.show()
            let result = AuthService.logoutUser()
            self.dismiss()
            
            switch result {
            case .success:
                // Clear uid / hasLogedIn = false
                LocalStorage.shared.clearUid()
                LocalStorage.shared.hasLogedIn = false
                
                let controller = LoginController()
                controller.delegate = self.tabBarController as? MainTabController
                
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                
            case .failure(let error):
                self.showFailure()
                print("DEBUG: Failed to signout with error: \(error.localizedDescription)")
            }
        }
        okAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in }
        cancelAction.setValue(UIColor.systemBrown, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc func handleRefresh() {
        fetchUserPosts()
        fetchUserStats()
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCell.identifier,
            for: indexPath) as? ProfileCell
        else { return UICollectionViewCell() }
        cell.viewModel = PostViewModel(post: posts[indexPath.item])
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ProfileHeader.identifier,
            for: indexPath
        ) as? ProfileHeader else { return UICollectionReusableView() }
        
        header.delegate = self
        header.viewModel = ProfileHeaderViewModel(user: user)
        
        return header
    }
    
}

// MARK: - UICollectionViewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.scrollDirection = .vertical
//        let controller = HomeController(collectionViewLayout: flowLayout)
//        controller.post = posts[indexPath.item]
//        navigationController?.pushViewController(controller, animated: true)
    }
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

// MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {

    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        if user.isCurrentUser {
            // Show edit profile
            
        } else if user.isFollowed {
            // Handle unfollow user
            UserService.unfollow(uid: user.uid) { _ in
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
            
            PostService.updateUserFeedAfterFollowing(user: user, didFollow: false)
            
        } else {
            // Handle follow user
            UserService.follow(uid: user.uid) { _ in
                self.user.isFollowed = true
                self.collectionView.reloadData()
            }
            
            // 通知被follow的人
            guard let currentUid = LocalStorage.shared.getUid() else { return }
            UserService.shared.fetchUserBy(uid: currentUid, completion: { currentUser in
                NotificationService.uploadNotification(
                    toUid: user.uid,
                    notiType: .follow,
                    fromUser: currentUser)
            })
                                    
            // 資料庫user-feed更新
            PostService.updateUserFeedAfterFollowing(user: user, didFollow: true)
        }
    }
}
