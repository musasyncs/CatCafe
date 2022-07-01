//
//  ConversationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import Foundation
import UIKit

class ChatlistController: UIViewController {
    
    var allRecents = [RecentChat]()
    var filteredRecents = [RecentChat]()
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    // MARK: - Views
    let tableView = UITableView()
    
    private lazy var newMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemBrown
        button.tintColor = .white
        button.imageView?.setDimensions(height: 24, width: 24)
        button.layer.cornerRadius = 56 / 2
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside)
        return button
    }()
    
    private lazy var backBarButtonItem = UIBarButtonItem(
        image: UIImage(systemName: "arrow.left")?
            .withTintColor(.black)
            .withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(showChatlist)
    )
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        tableView.register(RecentChatCell.self, forCellReuseIdentifier: RecentChatCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        // style
        view.backgroundColor = .white
        
        configureNavigationBar(withTitle: "\(UserService.shared.currentUser?.username ?? "")",
                               prefersLargeTitles: false,
                               shouldHideUnderline: true,
                               interfaceStyle: .light)
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        setupSearchController()
    
        // layout
        view.addSubview(tableView)
        view.addSubview(newMessageButton)
        tableView.frame = view.bounds
        newMessageButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                right: view.rightAnchor,
                                paddingBottom: 16,
                                paddingRight: 24)
        newMessageButton.setDimensions(height: 56, width: 56)
        
        // fetch
        downloadRecentChats()
    }
    
    // MARK: - Helper
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.placeholder = "搜尋"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .darkGray
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func filteredContentForSearchText(searchText: String) {
        filteredRecents = allRecents.filter({ (recent) -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }

    private func downloadRecentChats() {
        RecentChatService.shared.downloadRecentChatsFromFireStore { (allChats) in
            self.allRecents = allChats
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func goToChat(recent: RecentChat) {
        // make sure we have 2 recents
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        let controller = ChatController(chatId: recent.chatRoomId,
                                        recipientId: recent.receiverId,
                                        recipientName: recent.receiverName)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
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
        let recent = inSearchMode ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        cell.configure(recent: recent)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let recent = inSearchMode ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        RecentChatService.shared.clearUnreadCounter(recent: recent)
        goToChat(recent: recent)
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
            
            searchController.isActive
            ? self.filteredRecents.remove(at: indexPath.row)
            : allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
        
}

// MARK: - NewMessageControllerDelegate
extension ChatlistController: NewMessageControllerDelegate {
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User) {
        
        guard let currentUser = UserService.shared.currentUser else {
            print("DEBUG: Not getting current user")
            return
        }
        let chatId = startChat(user1: currentUser, user2: user)
        print("DEBUG: Start chatting chatroom id is ", chatId)
        
        // go to chat
        let controller = ChatController(chatId: chatId, recipientId: user.uid, recipientName: user.username)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ChatlistController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

// MARK: - UISearchBarDelegate
extension ChatlistController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
}
