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
    
    // MARK: - Views
    
    private let tableView = UITableView()
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar(withTitle: "New Messages",
                               prefersLargeTitles: false,
                               shouldHideUnderline: true,
                               interfaceStyle: .light)
        
        configureTableView()
        configureSearchController()
        
        fetchUsers()
        
        // setup pull to refresh
        let userRefresher = UIRefreshControl()
        userRefresher.addTarget(self, action: #selector(handleUserRefresh), for: .valueChanged)
        tableView.refreshControl = userRefresher
    }
    
    // MARK: - API
    
    func fetchUsers() {
        UserService.fetchUsers(exceptCurrentUser: true, completion: { users in
            self.users = users
            self.tableView.refreshControl?.endRefreshing()
        })
    }

    // MARK: - Helpers
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 64
        view.addSubview(tableView)
        tableView.fillSuperView()
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
    // MARK: - Actions
    
    @objc func handleUserRefresh() {
        fetchUsers()
    }
        
}

// MARK: - UITableViewDataSource / UITableViewDelegate

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
        navigationController?.popViewController(animated: false)
        delegate?.controller(self, wantsToStartChatWith: users[indexPath.item])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.white
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
}

// MARK: - UISearchResultsUpdating

extension NewMessageController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({
            $0.username.lowercased().contains(searchText.lowercased()) ||
            $0.fullname.lowercased().contains(searchText.lowercased())
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
