//
//  FeedController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class FeedController: UIViewController {
    
    var posts = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var post: Post? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    var showMenu = false
    
    // MARK: - View
    private let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    private let logoTextImageView = UIImageView()
    private let chatButton = UIButton(type: .system)
    private let notiButton = UIButton(type: .system)
    private let postButton = UIButton(type: .system)
    private lazy var logoBarButtonItem = UIBarButtonItem(customView: logoImageView)
    private lazy var logoTextBarButtonItem = UIBarButtonItem(customView: logoTextImageView)
    private lazy var chatBarButtonItem = UIBarButtonItem(customView: chatButton)
    private lazy var notiBarButtonItem = UIBarButtonItem(customView: notiButton)
    private lazy var postBarButtonItem = UIBarButtonItem(customView: postButton)
    private var dropTableView = UITableView(frame: .zero, style: .plain)
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        setupCollectionView()
        setupDropDownMenu()
        setupPullToRefresh()
        
        setupUpdateFeedObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCustomNavBar(backgroundType: .opaqueBackground,
                          shouldSetCustomBackImage: true,
                          backIndicatorImage: UIImage.asset(.Icons_24px_Back02))
        fetchPosts()
    }
    
    // MARK: - API
    func fetchPosts() {
        guard post == nil else {
            checkIfCurrentUserLikedPosts()
            self.collectionView.refreshControl?.endRefreshing()
            return
        }
        
        PostService.shared.fetchFeedPosts { posts in
            // 過濾出封鎖名單以外的 posts
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredPosts = posts.filter { !currentUser.blockedUsers.contains($0.user.uid) }
            self.posts = filteredPosts
                        
            self.checkIfCurrentUserLikedPosts()
            self.collectionView.refreshControl?.endRefreshing()
        }
        
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    private func checkIfCurrentUserLikedPosts() {
        if let post = post {
            PostService.shared.checkIfCurrentUserLikedPost(post: post) { isLiked in
                self.post?.isLiked = isLiked
            }
        } else {
            self.posts.forEach { post in
                PostService.shared.checkIfCurrentUserLikedPost(post: post) { isLiked in
                    if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                        self.posts[index].isLiked = isLiked
                    }
                }
            }
        }
    }
    
    // MARK: - Action
    @objc func gotoConversations() {
        if showMenu {
            handleDropDownMenu()
        }
        let controller = ChatlistController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func gotoNotificationPage() {
        if showMenu {
            handleDropDownMenu()
        }
        let controller = NotificationController()
        let navController = makeNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
    
    @objc func handleDropDownMenu() {
        showMenu = !showMenu
        let indexPaths = [IndexPath(row: 0, section: 0)]
        if showMenu {
            dropTableView.isHidden = false
            dropTableView.insertRows(at: indexPaths, with: .fade)
        } else {
            dropTableView.isHidden = true
            dropTableView.deleteRows(at: indexPaths, with: .fade)
        }
    }
    
    @objc func handleRefresh() {
        fetchPosts()
    }
    
}

extension FeedController {
    
    private func setupNavItems() {
        logoImageView.image = UIImage.asset(.logo)?
            .resize(to: .init(width: 32, height: 32))?
            .withRenderingMode(.alwaysOriginal)
        
        logoTextImageView.image = UIImage.asset(.logo_text)?
            .resize(to: .init(width: 80, height: 34))
        logoTextImageView.contentMode = .scaleAspectFit
        
        chatButton.setImage(
            UIImage.asset(.chat)?
                .resize(to: .init(width: 21, height: 21))?
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        chatButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        chatButton.addTarget(self, action: #selector(gotoConversations), for: .touchUpInside)
        
        notiButton.setImage(
            UIImage.asset(.like_unselected)?
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        notiButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        notiButton.addTarget(self, action: #selector(gotoNotificationPage), for: .touchUpInside)
        
        postButton.setImage(
            UIImage.asset(.plus_unselected)?
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        postButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        postButton.addTarget(self, action: #selector(handleDropDownMenu), for: .touchUpInside)
    
        navigationItem.leftBarButtonItems = post == nil ? [logoBarButtonItem, logoTextBarButtonItem] : nil
        navigationItem.rightBarButtonItems = post == nil ? [ chatBarButtonItem, notiBarButtonItem, postBarButtonItem
        ] : []
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor
        )
    }
 
    private func setupDropDownMenu() {
        dropTableView.register(DropDownCell.self, forCellReuseIdentifier: DropDownCell.identifier)
        dropTableView.delegate = self
        dropTableView.dataSource = self
        
        dropTableView.separatorStyle = .none
        dropTableView.isScrollEnabled = false
        dropTableView.rowHeight = 40
        dropTableView.backgroundColor = .white
        dropTableView.layer.cornerRadius = 4
        dropTableView.layer.shadowColor = UIColor.ccGrey.cgColor
        dropTableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dropTableView.layer.shadowOpacity = 0.2
        dropTableView.layer.shadowRadius = 4
        dropTableView.layer.masksToBounds = false
        dropTableView.isHidden = true
        
        view.addSubview(dropTableView)
        dropTableView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            right: view.rightAnchor, paddingRight: 20,
            width: 110, height: 40
        )
    }
    
    private func setupPullToRefresh() {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        if post == nil {
            collectionView.refreshControl = refresher
        } else {
            return
        }
    }
        
    private func setupUpdateFeedObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: CCConstant.NotificationName.updateFeed,
            object: nil
        )
    }
}

// MARK: - FeedCellDelegate
extension FeedController: FeedCellDelegate {
    
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
        UserService.shared.fetchUserBy(uid: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        UserService.shared.fetchUserBy(uid: currentUid, completion: { currentUser in
            cell.viewModel?.post.isLiked.toggle()
            
            if post.isLiked {
                PostService.shared.unlikePost(post: post) { likeCount in
                    cell.viewModel?.post.likes = likeCount
                }
            } else {
                PostService.shared.likePost(post: post) { likeCount in
                    cell.viewModel?.post.likes = likeCount
                    
                    // 發like通知給對方
                    NotificationService.uploadNotification(
                        toUid: post.ownerUid,
                        notiType: .like,
                        fromUser: currentUser,
                        post: post
                    )
                }
            }
            
        })
        
    }
    
    func cell(_ cell: FeedCell, showCommentsFor post: Post) {
        let controller = FeedCommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FeedController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedCell.identifier,
            for: indexPath) as? FeedCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self

        if let post = post {
            cell.viewModel = PostViewModel(post: post)
            
            // comments count
            CommentService.fetchComments(forPost: post.postId) { comments in
                cell.viewModel?.comments = comments
            }
            
        } else {
            cell.viewModel = PostViewModel(post: posts[indexPath.item])
            
            // comments count
            CommentService.fetchComments(forPost: posts[indexPath.item].postId) { comments in
                cell.viewModel?.comments = comments
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
                
        let approximateWidthOfTextArea = UIScreen.width - 8 - 8
        let approximateSize = CGSize(width: approximateWidthOfTextArea, height: 1000)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)]
        
        let estimatedHeight = 12 + 40 + 8 + UIScreen.width + 8 + 8 + 16 + 8 + (8)
        
        // Get an estimation of the height of cell based on post.caption
        if let post = post {
            let estimatedFrame = String(describing: post.caption).boundingRect(
                with: approximateSize,
                options: .usesLineFragmentOrigin,
                attributes: attributes,
                context: nil)
            return CGSize(
                width: view.frame.width,
                height: estimatedFrame.height + estimatedHeight
            )
        } else {
            let estimatedFrame = String(describing: posts[indexPath.item].caption).boundingRect(
                with: approximateSize,
                options: .usesLineFragmentOrigin,
                attributes: attributes,
                context: nil)
            return CGSize(
                width: view.frame.width,
                height: estimatedFrame.height + estimatedHeight
            )
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension FeedController: UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return presentTransition
        }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource - Drop down menu
extension FeedController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showMenu ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DropDownCell.identifier,
            for: indexPath
        ) as? DropDownCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            cell.titleLabel.text = "發佈"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            handleDropDownMenu()
            
            presentTransition = CustomAnimationPresentor()
            dismissTransition = CustomAnimationDismisser()
            
            let navController = makeNavigationController(rootViewController: PostSelectController())
            navController.modalPresentationStyle = .custom
            navController.transitioningDelegate = self
            
            present(navController, animated: true, completion: { [weak self] in
                self?.presentTransition = nil
            })
        }
    }
}
