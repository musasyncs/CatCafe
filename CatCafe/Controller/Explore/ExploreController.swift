//
//  ExploreController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

class ExploreController: UIViewController {
    
    private var posts = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
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
    private lazy var backBarButtonItem = UIBarButtonItem(
        image: SFSymbols.arrow_left?
            .withTintColor(.ccGrey)
            .withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(showCollectionView)
    )
    
    private let tableView = UITableView()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupCollectionView()
        setupSearchController()
        setupPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
        fetchPosts()
    }
    
    // MARK: - API
    private func fetchUsers() {
        UserService.shared.fetchUsers(exceptCurrentUser: true, completion: { [weak self] users in
            guard let self = self else { return }
            self.users = users
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    private func fetchPosts() {
        PostService.shared.fetchPosts { [weak self] result in
            guard let self = self else { return }
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

    // MARK: - Action
    @objc func showCollectionView() {
        searchController.searchBar.endEditing(true)
        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.text = nil
        collectionView.isHidden = false
        tableView.isHidden = true
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc func handlePostRefresh() {
        fetchPosts()
    }
    
    @objc func handleUserRefresh() {
        fetchUsers()
    }
            
}

extension ExploreController {
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 72
        tableView.isHidden = true
        
        view.addSubview(tableView)
        tableView.fillSuperView()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.fillSuperView()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.placeholder = "搜尋"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .ccGreyVariant
        navigationItem.titleView = searchController.searchBar
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setupPullToRefresh() {
        let postRefresher = UIRefreshControl()
        let userRefresher = UIRefreshControl()
        postRefresher.addTarget(self, action: #selector(handlePostRefresh), for: .valueChanged)
        userRefresher.addTarget(self, action: #selector(handleUserRefresh), for: .valueChanged)
        collectionView.refreshControl = postRefresher
        tableView.refreshControl = userRefresher
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ExploreController: UITableViewDataSource, UITableViewDelegate {
    
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
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - UISearchResultsUpdating
extension ExploreController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({
            $0.username.contains(searchText) || $0.fullname.contains(searchText)
        })
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension ExploreController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        collectionView.isHidden = true
        tableView.isHidden = false
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate
extension ExploreController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        else {
            return UICollectionViewCell()
        }
        cell.viewModel = PostViewModel(post: posts[indexPath.item])
        return cell
    }
    
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
extension ExploreController: UICollectionViewDelegateFlowLayout {
    
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
        return .init(top: 0, left: 18, bottom: 0, right: 18)
    }

}
