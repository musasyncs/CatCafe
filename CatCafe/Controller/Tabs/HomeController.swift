//
//  HomeController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class HomeController: UICollectionViewController {
    
    var posts = [Post]()
    var post: Post?
        
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    let chatButton = UIButton(type: .system)
    let notiButton = UIButton(type: .system)
    let postButton = UIButton(type: .system)
    lazy var chatBarButtonItem = UIBarButtonItem(customView: chatButton)
    lazy var notiBarButtonItem = UIBarButtonItem(customView: notiButton)
    lazy var postBarButtonItem = UIBarButtonItem(customView: postButton)
    var showMenu = false
    var dropTableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRightNavItems()
        setupCollectionView()
        setupDropDownMenu()
        
        setupUpdateFeedObserver()
        fetchPosts()
    }
    
    // MARK: - API
    
    func fetchPosts() {
        guard post == nil else {
            collectionView.refreshControl?.endRefreshing()
            collectionView.reloadData()
            return
        }
        
        PostService.fetchPosts { posts in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    private func setupRightNavItems() {
        chatButton.setImage(UIImage(named: "send2")?.withRenderingMode(.alwaysOriginal), for: .normal)
        chatButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        chatButton.addTarget(self, action: #selector(gotoChatRoom), for: .touchUpInside)
        
        notiButton.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        notiButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        notiButton.addTarget(self, action: #selector(gotoNotificationPage), for: .touchUpInside)
        
        postButton.setImage(UIImage(named: "plus_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        postButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        postButton.addTarget(self, action: #selector(handleDropDownMenu), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [chatBarButtonItem, notiBarButtonItem, postBarButtonItem]
    }
    
    func setupCollectionView() {
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        
        // setup pull to refresh
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    func setupDropDownMenu() {
        dropTableView.register(DropDownCell.self, forCellReuseIdentifier: DropDownCell.identifier)
        dropTableView.delegate = self
        dropTableView.dataSource = self
    
        dropTableView.separatorStyle = .singleLine
        dropTableView.isScrollEnabled = false
        dropTableView.rowHeight = 40
        dropTableView.backgroundColor = .clear
        dropTableView.layer.cornerRadius = 4
    
        view.addSubview(dropTableView)
        dropTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 right: view.rightAnchor, paddingRight: 20,
                                 width: 110, height: 80)
    }
    
    func setupUpdateFeedObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: CCConstant.NotificationName.updateFeed,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc func gotoChatRoom() {
        
    }
    
    @objc func gotoNotificationPage() {
        
    }
    
    @objc func handleDropDownMenu() {
        showMenu = !showMenu
        let indexPaths = [IndexPath(row: 0, section: 0),
                          IndexPath(row: 1, section: 0)]
        if showMenu {
            dropTableView.insertRows(at: indexPaths, with: .fade)
        } else {
            dropTableView.deleteRows(at: indexPaths, with: .fade)
        }
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }
    
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension HomeController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedCell.identifier,
            for: indexPath) as? FeedCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let viewModel: PostViewModel?
        
        if let post = post {
            viewModel = PostViewModel(post: post)
        } else {
            viewModel = PostViewModel(post: posts[indexPath.item])
        }
        
        viewModel?.fetchUserDataByOwnerUid {
            cell.viewModel = viewModel
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        return CGSize(width: width, height: height)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension HomeController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource - Drop down menu

extension HomeController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showMenu ? 2 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DropDownCell.identifier,
            for: indexPath
        ) as? DropDownCell else { return UITableViewCell() }
                
        if indexPath.row == 0 {
            cell.titleLabel.text = "發佈"
        } else {
            cell.titleLabel.text = "限時動態"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            handleDropDownMenu()
            
            presentTransition = CustomAnimationPresentor()
            dismissTransition = CustomAnimationDismisser()
            
            let navController = UINavigationController(rootViewController: PostSelectController())
            navController.modalPresentationStyle = .custom
            navController.transitioningDelegate = self
            
            present(navController, animated: true, completion: { [weak self] in
                self?.presentTransition = nil
            })
            
        } else {
            
        }
    }
}

// MARK: - FeedCellDelegate

extension HomeController: FeedCellDelegate {
    func cell(_ cell: FeedCell, showCommentsFor post: Post) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let controller = CommentController(collectionViewLayout: layout)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
