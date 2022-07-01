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
    private lazy var backBarButtonItem = UIBarButtonItem(
        image: UIImage(systemName: "arrow.left")?
            .withTintColor(.black)
            .withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(showCollectionView)
    )
    
    let mapButton = makeIconButton(
        imagename: "map",
        imageColor: .black,
        imageWidth: 24,
        imageHeight: 24
    )
    lazy var mapBarButtonItem = UIBarButtonItem(customView: mapButton)
    
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
        configureUI()
        configureSearchController()
        
        fetchUsers()
        fetchPosts()
        
        // setup pull to refresh
        let postRefresher = UIRefreshControl()
        let userRefresher = UIRefreshControl()
        postRefresher.addTarget(self, action: #selector(handlePostRefresh), for: .valueChanged)
        userRefresher.addTarget(self, action: #selector(handleUserRefresh), for: .valueChanged)
        collectionView.refreshControl = postRefresher
        tableView.refreshControl = userRefresher
    }
    
    // MARK: - API
    func fetchUsers() {
        UserService.fetchUsers(exceptCurrentUser: true, completion: { users in
            self.users = users
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    func fetchPosts() {
        PostService.fetchPosts { posts in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.rowHeight = 64
        tableView.isHidden = true
        view.addSubview(tableView)
        tableView.fillSuperView()
        
        view.addSubview(collectionView)
        collectionView.fillSuperView()
    }
    
    func configureSearchController() {
        navigationItem.rightBarButtonItem = mapBarButtonItem
        mapButton.addTarget(self, action: #selector(showMap), for: .touchUpInside)

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.placeholder = "搜尋"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .darkGray
        navigationItem.titleView = searchController.searchBar
        navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Actions
    @objc func showCollectionView() {
        searchController.searchBar.endEditing(true)
        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.text = nil
        collectionView.isHidden = false
        tableView.isHidden = true
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc func showMap() {
        print("did tap show map")
    }
    
    @objc func handlePostRefresh() {
        fetchPosts()
    }
    
    @objc func handleUserRefresh() {
        fetchUsers()
    }
        
}

// MARK: - UITableViewDataSource / UITableViewDelegate
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
        let controller = ProfileController(user: users[indexPath.row])
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
        self.tableView.reloadData()
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
            for: indexPath) as? ProfileCell else {
                return UICollectionViewCell()
            }
        cell.viewModel = PostViewModel(post: posts[indexPath.item])
        return cell
    }
    
}

// MARK: - UICollectionViewFlowLayout
extension ExploreController: UICollectionViewDelegateFlowLayout {
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

}
