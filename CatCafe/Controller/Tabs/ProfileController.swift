//
//  ProfileController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class ProfileController: UIViewController {
    
    private var user: User {
        didSet {
            profileImageView.loadImage(user.profileImageUrlString)
        }
    }
    private var posts = [Post]()
    
    // MARK: - View
    private let topImageView = TopImageView(frame: .zero)
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        collectionView.register(
            ProfileHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeader.identifier
        )
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.layer.cornerRadius = 12
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return collectionView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 100 / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 5
        imageView.backgroundColor = .gray6
        return imageView
    }()
    
    private let deleteAccountAlert = DeleteAccountAlert()
    
    // MARK: - Initializer
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        setupNavBar()
        setupCollectionView()
        setupProfileImageView()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        checkIfUserIsFollowed()
        fetchUserStats()
        fetchUserPosts()
        
        checkIfUserIsBlocked()
    }
    
    // MARK: - Config
    private func setupImageView() {
        view.addSubview(topImageView)
        topImageView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: UIScreen.height * 0.3
        )
    }
    
    private func setupNavBar() {
        setupCustomNavBar(
            backgroundType: .transparentBackground,
            shouldSetCustomBackImage: true,
            backIndicatorImage: UIImage.asset(.Icons_24px_Back02)?.withTintColor(.white)
        )
        
        let logoutBarButtonItem = UIBarButtonItem(
            image: UIImage.asset(.logout)?
                .resize(to: .init(width: 20, height: 20))?
                .withTintColor(.white)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleLogout)
        )
            
        navigationItem.rightBarButtonItems = [logoutBarButtonItem]
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: UIScreen.height * 0.2
        )
    }
    
    private func setupProfileImageView() {
        view.addSubview(profileImageView)
        profileImageView.centerX(inView: view)
        profileImageView.anchor(top: collectionView.topAnchor,
                                paddingTop: -55)
        profileImageView.setDimensions(height: 100, width: 100)
    }
    
    private func setupRefreshControl() {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    // MARK: - API
    private func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUserPosts() {
        PostService.shared.fetchPosts(forUser: user.uid) { result in
            switch result {
            case .success(let posts):
                self.posts = posts
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            case .failure:
                self.collectionView.refreshControl?.endRefreshing()
                self.showFailure(text: "網路異常")
            }
        }
    }
    
    private func checkIfUserIsBlocked() {
        UserService.shared.checkIfUserIsBlocked(uid: user.uid) { isBlocked in
            self.user.isBlocked = isBlocked
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Action
    @objc func handleRefresh() {
        fetchUserPosts()
        fetchUserStats()
    }
    
    @objc func handleLogout() {
        // 還沒登入要先登入
        if UserService.shared.currentUser == nil {
            showMessage(withTitle: "Oops", message: "請先登入")
            return
        }
        
        let alert = UIAlertController(title: "是否登出？", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            self.show()
            let result = AuthService.shared.logoutUser()
            
            switch result {
            case .success:
                self.dismiss()
                
                LocalStorage.shared.clearUid()
                LocalStorage.shared.hasLogedIn = false
                UserService.shared.currentUser = nil // 更新 currentUser
                
                let controller = LoginController()
                controller.delegate = self.tabBarController as? MainTabController
                let nav = makeNavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                
            case .failure:
                self.dismiss()
                self.showFailure(text: "登出失敗")
            }
        }
        okAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in }
        cancelAction.setValue(UIColor.ccPrimary, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc func dissmissAlert() {
        deleteAccountAlert.dissmissAlert()
    }
    
    @objc func deleteAccount() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        self.show()
        currentUser.delete(completion: { error in
            if let error = error {
                self.dismiss()
                print("Error deleting account: \(error)")
            } else {
                self.dismiss()

                LocalStorage.shared.clearUid()
                LocalStorage.shared.hasLogedIn = false
                UserService.shared.currentUser = nil // 更新 currentUser

                self.deleteAccountAlert.dissmissAlert()
                
                let controller = LoginController()
                controller.delegate = self.tabBarController as? MainTabController
                let nav = makeNavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        })
    }
    
}

// MARK: - UICollectionViewDataSource
extension ProfileController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(
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
    
    func collectionView(
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
extension ProfileController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let controller = FeedController()
        controller.post = posts[indexPath.item]
        let navController = makeNavigationController(rootViewController: controller)
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (view.frame.width - 36 - 5 * 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(top: 8, left: 18, bottom: 0, right: 18)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        // 還沒登入要先登入
        if UserService.shared.currentUser == nil {
            showMessage(withTitle: "Oops", message: "請先登入")
            return
        }
        
        if user.isCurrentUser {
            // Show edit profile
            let controller = ProfileEditController()
            controller.user = self.user
            controller.modalPresentationStyle = .overFullScreen
            present(controller, animated: true)
            
        } else if user.isFollowed {
            // Handle unfollow user
            UserService.shared.unfollow(uid: user.uid) { _ in
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
            
            PostService.shared.updateUserFeedAfterFollowing(user: user, didFollow: false)
            
        } else {
            // Handle follow user
            UserService.shared.follow(uid: user.uid) { _ in
                self.user.isFollowed = true
                self.collectionView.reloadData()
            }
            
            // 通知被follow的人
            guard let currentUid = LocalStorage.shared.getUid() else { return }
            UserService.shared.fetchUserBy(uid: currentUid, completion: { currentUser in
                NotificationService.shared.uploadNotification(
                    toUid: user.uid,
                    notiType: .follow,
                    fromUser: currentUser)
            })
            
            // 資料庫user-feed更新
            PostService.shared.updateUserFeedAfterFollowing(user: user, didFollow: true)
        }
    }
    
    func header(_ profileHeader: ProfileHeader) {
        deleteAccountAlert.showAlert(on: self)
    }
    
    func header(_ profileHeader: ProfileHeader, wantToChatWith user: User) {
        // 還沒登入要先登入
        guard let currentUser = UserService.shared.currentUser else {
            showMessage(withTitle: "Oops", message: "請先登入")
            return
        }
        
        // 封鎖過不可聊天
        if currentUser.blockedUsers.contains(user.uid) {
            showMessage(withTitle: "您已封鎖此使用者", message: "無法進行聊天")
            return
        }
            
        let chatId = startChat(user1: currentUser, user2: user)
        
        let controller = ChatController(chatId: chatId, recipientId: user.uid, recipientName: user.username)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func header(_ profileHeader: ProfileHeader, didTapBlock user: User) {
        // 還沒登入要先登入
        if UserService.shared.currentUser == nil {
            showMessage(withTitle: "Oops", message: "請先登入")
            return
        }
        
        if user.isBlocked {
            UserService.shared.unblock(uid: user.uid) { error in
                if let error = error {
                    print("Failed to unblock with error: \(error.localizedDescription)")
                    return
                }
                
                self.user.isBlocked = false
                UserService.shared.fetchCurrentUser { _ in } // 更新 currentUser
                
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.block(uid: user.uid) { error in
                if let error = error {
                    print("Failed to block with error: \(error.localizedDescription)")
                    return
                }
                
                self.user.isBlocked = true
                UserService.shared.fetchCurrentUser { _ in } // 更新 currentUser
                
                self.collectionView.reloadData()
            }
        }
    }
    
}

class TopImageView: UIImageView {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image = UIImage.asset(.profile_back)
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        layer.addSublayer(gradientLayer)
        gradientLayer.frame = self.bounds
    }
}
