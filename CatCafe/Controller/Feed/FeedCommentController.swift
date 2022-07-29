//
//  FeedCommentController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import UIKit

class FeedCommentController: UICollectionViewController {
    
    private let post: Post
    private var comments = [Comment]()
    
    // MARK: - View
    private lazy var commentInputView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let inputView = CommentInputAccessoryView(frame: frame)
        inputView.delegate = self
        return inputView
    }()
    
    override var inputAccessoryView: UIView? {
        return commentInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Init
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar(
            backgroundType: .opaqueBackground,
            shouldSetCustomBackImage: true,
            backIndicatorImage: UIImage.asset(.Icons_24px_Back02)
        )
        setupCollectionView()
        setupDismissKeyboardWhenTapped()
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - API
    private func fetchComments() {
        CommentService.shared.fetchComments(forPost: post.postId) { [weak self] comments in
            guard let self = self else { return }
            
            // 過濾出封鎖名單以外的 comments
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredComments = comments.filter { !currentUser.blockedUsers.contains($0.user.uid) }
            self.comments = filteredComments
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Action
    @objc func dismissKeyboard() {
        commentInputView.commentTextView.resignFirstResponder()
    }
}

extension FeedCommentController {
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    
    private func setupDismissKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(tap)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FeedCommentController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommentCell.identifier,
            for: indexPath) as? CommentCell
        else { return UICollectionViewCell() }
        
        let comment = comments[indexPath.item]
        cell.viewModel = CommentViewModel(comment: comment)

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let uid = comments[indexPath.item].uid
        UserService.shared.fetchUserBy(uid: uid) { [weak self] user in
            guard let self = self else { return }
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowlayout
extension FeedCommentController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let viewModel = CommentViewModel(comment: comments[indexPath.item])
        let height = viewModel.size(forWidth: view.frame.width).height + 32
        return CGSize(width: view.frame.width, height: height)
    }
    
}

// MARK: - CommentInputAccessoryViewDelegate
extension FeedCommentController: CommentInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        UserService.shared.fetchUserBy(uid: currentUid, completion: { [weak self] currentUser in
            guard let self = self else { return }
            
            self.showHud()
            CommentService.shared.uploadComment(
                postId: self.post.postId,
                user: currentUser,
                commentType: 0,
                mediaUrlString: "",
                comment: comment
            ) { [weak self] error in
                guard let self = self else { return }
                
                if error != nil {
                    self.dismissHud()
                    self.showFailure(text: "Failed to upload comment")
                    return
                }
                
                self.dismissHud()
                inputView.clearCommentTextView()
                inputView.postButton.isEnabled = false
                inputView.postButton.setTitleColor(UIColor.lightGray, for: .normal)
                
                self.dismissKeyboard()
                
                // 通知被留言的人
                NotificationService.shared.uploadNotification(
                    toUid: self.post.ownerUid,
                    notiType: .comment,
                    fromUser: currentUser,
                    post: self.post
                )
            }
        })
                                
    }
}
