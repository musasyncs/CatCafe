//
//  NotificationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

class NotificationController: UIViewController {
    
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let refresher = UIRefreshControl()
    
    // MARK: - View
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        fetchnotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createGradientBackground()
    }
    
    // MARK: - API
    func fetchnotifications() {
        NotificationService.fetchNotifications { notifications in
            
            // 過濾出封鎖名單以外的 notifications
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredNotifications = notifications.filter { !currentUser.blockedUsers.contains($0.fromUid) }
            self.notifications = filteredNotifications
            
            self.checkIfUserIsFollowed()
        }
    }
    
    func checkIfUserIsFollowed() {
        notifications.forEach { notification in
            guard notification.notiType == .follow else { return }
            
            UserService.shared.checkIfUserIsFollowed(uid: notification.fromUid) { userIsFollowed in
                if let index = self.notifications.firstIndex(where: { $0.notiId == notification.notiId }) {
                    self.notifications[index].userIsFollowed = userIsFollowed
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func didTapClose() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func handleRefresh() {
        fetchnotifications()
        tableView.refreshControl?.endRefreshing()
    }
}

extension NotificationController {
    
    func setupTableView() {
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
    
    func setupNavBar() {
        setupCustomNavBar(
            backgroundType: .transparentBackground,
            shouldSetCustomBackImage: false,
            backIndicatorImage: nil
        )
        
        title = "動態"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left")?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NotificationController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.identifier,
            for: indexPath) as? NotificationCell
        else { return UITableViewCell() }
        
        let notification = notifications[indexPath.section]
        cell.viewModel = NotificationViewModel(notification: notification)
        
        // profileImageUrl, username
        UserService.shared.fetchUserBy(uid: notification.fromUid) { user in
            cell.viewModel?.profileImageUrlString = user.profileImageUrlString
            cell.viewModel?.username  = user.username
        }
        
        // mediaUrl
        if notification.postId.isEmpty {
            // is followed
            cell.viewModel?.mediaUrlString = nil
        } else {
            // is liked or commented
            PostService.shared.fetchPost(withPostId: notification.postId) { result in
                switch result {
                case .success(let post):
                    self.dismiss()
                    cell.viewModel?.mediaUrlString = post.mediaUrlString
                case .failure:
                    self.dismiss()
                    self.showFailure(text: "無法讀取貼文")
                }
            }
        }
        cell.delegate = self
        return cell
    }
    
}

// MARK: - NotificationCellDelegate
extension NotificationController: NotificationCellDelegate {
    
    func cell(_ cell: NotificationCell, wantsToViewProfile uid: String) {
        UserService.shared.fetchUserBy(uid: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
        PostService.shared.fetchPost(withPostId: postId) { result in
            switch result {
            case .success(let post):
                let flowLayout = UICollectionViewFlowLayout()
                flowLayout.scrollDirection = .vertical
                let controller = FeedController()
                controller.post = post
                self.navigationController?.pushViewController(controller, animated: true)
            case .failure:
                self.showFailure(text: "無法讀取貼文")
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
        UserService.follow(uid: uid) { _ in
            cell.viewModel?.notification.userIsFollowed.toggle()
            UserService.shared.fetchUserBy(uid: uid) { user in
                PostService.shared.updateUserFeedAfterFollowing(user: user, didFollow: true)
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String) {
        UserService.unfollow(uid: uid) { _ in
            cell.viewModel?.notification.userIsFollowed.toggle()
            UserService.shared.fetchUserBy(uid: uid) { user in
                PostService.shared.updateUserFeedAfterFollowing(user: user, didFollow: false)
            }
        }
    }
    
}
