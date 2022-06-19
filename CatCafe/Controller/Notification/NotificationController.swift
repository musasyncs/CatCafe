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
        navigationItem.title = "Notifications"
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: false, completion: nil)
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

        return cell
    }
}
