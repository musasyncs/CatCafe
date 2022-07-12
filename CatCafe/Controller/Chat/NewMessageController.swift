//
//  NewMessageController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import UIKit

protocol NewMessageControllerDelegate: AnyObject {
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User)
}

class NewMessageController: UIViewController {
    
    weak var delegate: NewMessageControllerDelegate?
    
    private var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var filteredUsers = [User]()
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "新訊息"
        setupTableView()
        setupSearchController()
        setupPullToRefresh()
        
        fetchUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createGradientBackground()
    }
    
    // MARK: - API
    private func fetchUsers() {
        UserService.fetchUsers(exceptCurrentUser: true, completion: { users in
            
            // 過濾出封鎖名單以外的 users
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredUsers = users.filter { !currentUser.blockedUsers.contains($0.uid) }
            self.users = filteredUsers
            
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    // MARK: - Action
    @objc func handleUserRefresh() {
        fetchUsers()
    }
    
}

extension NewMessageController {
    
    private func setupTableView() {
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.register(
            MessageSectionHeader.self,
            forHeaderFooterViewReuseIdentifier: MessageSectionHeader.identifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.rowHeight = 80
        view.addSubview(tableView)
        tableView.fillSuperView()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "搜尋"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .ccPrimary
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupPullToRefresh() {
        let userRefresher = UIRefreshControl()
        userRefresher.addTarget(self, action: #selector(handleUserRefresh), for: .valueChanged)
        tableView.refreshControl = userRefresher
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewMessageController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as? UserCell
        else { return UITableViewCell() }
        
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserCellViewModel(user: user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
        delegate?.controller(self, wantsToStartChatWith: users[indexPath.item])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MessageSectionHeader.identifier
        ) as? MessageSectionHeader else { return nil }
        headerView.titleLabel.text = "建議"
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
}

// MARK: - UISearchResultsUpdating
extension NewMessageController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({
            $0.username.lowercased().contains(searchText) ||
            $0.fullname.lowercased().contains(searchText)
        })
        self.tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension NewMessageController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        tableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        tableView.isHidden = true
    }
    
}
