//
//  NotificationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

class NotificationController: UITableViewController {
    
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let refresher = UIRefreshControl()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBarButtonItem()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchnotifications()
    }
    
    // MARK: - API
    
    func fetchnotifications() {
        NotificationService.fetchNotifications { notifications in
            self.notifications = notifications
            self.checkIfUserIsFollowed()
        }
    }
    
    func checkIfUserIsFollowed() {
        notifications.forEach { notification in
            guard notification.notiType == .follow else { return }
            
            UserService.checkIfUserIsFollowed(uid: notification.fromUid) { userIsFollowed in
                if let index = self.notifications.firstIndex(where: { $0.notiId == notification.notiId }) {
                    self.notifications[index].userIsFollowed = userIsFollowed
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func setupBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
    }
    
    func setupTableView() {
        view.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
    }
    
    // MARK: - Actions
    
    @objc func didTapClose() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchnotifications()
        refresher.endRefreshing()
    }
}

extension NotificationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.identifier,
            for: indexPath) as? NotificationCell
        else { return UITableViewCell() }
        
        let notification = notifications[indexPath.row]
        cell.viewModel = NotificationViewModel(notification: notification)
        
        // profileImageUrl, username
        UserService.fetchUserBy(uid: notification.fromUid) { user in
            cell.viewModel?.profileImageUrl = URL(string: user.profileImageUrlString)
            cell.viewModel?.username  = user.username
        }
        
        // mediaUrl
        if notification.postId.isEmpty {
            // is followed
            cell.viewModel?.mediaUrl = nil
        } else {
            // is liked or commented
            PostService.fetchPost(withPostId: notification.postId) { post in
                cell.viewModel?.mediaUrl = URL(string: post.mediaUrlString)
            }
        }
        
        cell.delegate = self
        return cell
    }
    
}

// MARK: - NotificationCellDelegate

extension NotificationController: NotificationCellDelegate {
    
    func cell(_ cell: NotificationCell, wantsToViewProfile uid: String) {
        showLoader(true)
        UserService.fetchUserBy(uid: uid) { user in
            self.showLoader(false)
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
        showLoader(true)
        PostService.fetchPost(withPostId: postId) { post in
            self.showLoader(false)
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .vertical
            let controller = HomeController(collectionViewLayout: flowLayout)
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
        showLoader(true)
        UserService.follow(uid: uid) { _ in
            self.showLoader(false)
            cell.viewModel?.notification.userIsFollowed.toggle()
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String) {
        showLoader(true)
        UserService.unfollow(uid: uid) { _ in
            self.showLoader(false)
            cell.viewModel?.notification.userIsFollowed.toggle()
        }
    }
    
}
