//
//  ConversationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import Foundation
import UIKit

class ChatlistController: UIViewController {
    
    private var allRecents = [RecentChat]()
    private var filteredRecents = [RecentChat]()
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private lazy var newMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(SFSymbols.plus, for: .normal)
        button.backgroundColor = .ccPrimary
        button.tintColor = .white
        button.imageView?.setDimensions(height: 24, width: 24)
        button.layer.cornerRadius = 56 / 2
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside)
        return button
    }()
    
    private lazy var backBarButtonItem = UIBarButtonItem(
        image: SFSymbols.arrow_left?
            .withTintColor(.ccGrey)
            .withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(showChatlist)
    )
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createGradientBackground()
        title = UserService.shared.currentUser?.username ?? ""
        
        setupCustomNavBar(
            backgroundType: .transparentBackground,
            shouldSetCustomBackImage: true,
            backIndicatorImage: UIImage.asset(.Icons_24px_Back02)
        )
        setupTableView()
        setupSearchController()
        setupNewMessageButton()
        
        downloadRecentChats()
    }
    
    // MARK: - API
    private func downloadRecentChats() {
        RecentChatService.shared.downloadRecentChatsFromFireStore { [weak self] allRecents in
            guard let self = self else { return }
            
            // 過濾出封鎖名單以外的 allRecents
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredRecents = allRecents.filter { !currentUser.blockedUsers.contains($0.senderId) &&
                !currentUser.blockedUsers.contains($0.receiverId)
            }
            self.allRecents = filteredRecents
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Action
    @objc func showChatlist() {
        searchController.searchBar.endEditing(true)
        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.text = nil
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc func showNewMessage() {
        let controller = NewMessageController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ChatlistController {
    
    private func setupTableView() {
        tableView.register(RecentChatCell.self, forCellReuseIdentifier: RecentChatCell.identifier)
        tableView.register(MessageSectionHeader.self,
                           forHeaderFooterViewReuseIdentifier: MessageSectionHeader.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.rowHeight = 80
        view.addSubview(tableView)
        tableView.fillSuperView()
    }
    
    private func setupNewMessageButton() {
        view.addSubview(newMessageButton)
        newMessageButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                right: view.rightAnchor,
                                paddingBottom: 16,
                                paddingRight: 16)
        newMessageButton.setDimensions(height: 56, width: 56)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.placeholder = "搜尋"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .ccPrimary
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ChatlistController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredRecents.count : allRecents.count        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecentChatCell.identifier,
            for: indexPath) as? RecentChatCell
        else { return UITableViewCell() }
        cell.recent = inSearchMode ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = inSearchMode ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        RecentChatService.shared.clearUnreadCounter(recent: recent)
        
        // make sure we have 2 recents
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        let controller = ChatController(
            chatId: recent.chatRoomId,
            recipientId: recent.receiverId,
            recipientName: recent.receiverName
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            RecentChatService.shared.deleteRecent(recent)
            
            if searchController.isActive {
                filteredRecents.remove(at: indexPath.row)
            } else {
                allRecents.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MessageSectionHeader.identifier
        ) as? MessageSectionHeader else { return nil }
        headerView.titleLabel.text = "訊息"
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
        
}

// MARK: - NewMessageControllerDelegate
extension ChatlistController: NewMessageControllerDelegate {
    
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User) {
        guard let currentUser = UserService.shared.currentUser else { return }
        let chatId = startChat(user1: currentUser, user2: user)
        
        let controller = ChatController(chatId: chatId, recipientId: user.uid, recipientName: user.username)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - UISearchResultsUpdating
extension ChatlistController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredRecents = allRecents.filter({
            $0.receiverName.lowercased().contains(searchText)
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension ChatlistController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
}
