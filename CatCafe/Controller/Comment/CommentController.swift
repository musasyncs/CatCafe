//
//  CommentController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import Foundation
import UIKit

class CommentController: UICollectionViewController {
    
    private let post: Post
    
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
    
    // MARK: - Life Cycle
    
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helpers
    
    func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.identifier, for: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowlayout

extension CommentController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
}

// MARK: - CommentInputAccessoryViewDelegate

extension CommentController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        // 拿目前user
        guard let tabBarController = tabBarController as? MainTabController else { return }
        guard let user = tabBarController.user else { return }
        
        showLoader(true)
        
        CommentService.uploadComment(
            postId: post.postId,
            user: user,
            commentType: 0,
            mediaUrlString: "",
            comment: comment
        ) { error in
            self.showLoader(false)
            
            if let error = error {
                print("DEBUG: Failed to upload comment with error \(error.localizedDescription)")
                return
            }

            inputView.clearCommentTextView()
        }
    }
}
