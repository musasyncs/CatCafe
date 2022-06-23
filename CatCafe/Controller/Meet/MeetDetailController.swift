//
//  MeetDetailController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

class MeetDetailController: UICollectionViewController {
    
    private let meet: Meet
    private var comments = [Comment]()
    private var people = [User]()
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let inputView = CommentInputAccessoryView(frame: frame)
        inputView.delegate = self
        return inputView
    }()
    
    override var inputAccessoryView: UIView? { return commentInputView }
    override var canBecomeFirstResponder: Bool { return true }
        
    // MARK: - Life Cycle
        
    init(meet: Meet) {
        self.meet = meet
        super.init(collectionViewLayout: StretchyHeaderLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
    
    // MARK: - Helpers
    
    // MARK: - API
    
    func fetchComments() {
        CommentService.fetchMeetComments(forMeet: meet.meetId) { comments in
            self.comments = comments
            self.collectionView.reloadData()
        }
    }

}

extension MeetDetailController {

    func setupCollectionView() {
        collectionView.register(
            MeetStretchyHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MeetStretchyHeader.identifier
        )
        collectionView.register(
            CommentSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CommentSectionHeader.identifier
        )
        collectionView.register(
            CommentCell.self,
            forCellWithReuseIdentifier: CommentCell.identifier
        )
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension MeetDetailController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return comments.count
        }
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
        
        UserService.fetchUserBy(uid: comment.uid) { user in
            cell.viewModel?.username = user.username
            cell.viewModel?.profileImageUrl = URL(string: user.profileImageUrlString)
        }
        
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MeetStretchyHeader.identifier,
                for: indexPath
            ) as? MeetStretchyHeader else { return UICollectionReusableView() }
            header.imageUrlString = meet.mediaUrlString
            return header
            
        } else {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CommentSectionHeader.identifier,
                for: indexPath
            ) as? CommentSectionHeader else { return UICollectionReusableView() }
                        
            header.delegate = self
            header.viewModel = MeetViewModel(meet: meet)
            
            UserService.fetchUserBy(uid: meet.ownerUid) { user in
                header.viewModel?.ownerUsername = user.username
                header.viewModel?.ownerImageUrl = URL(string: user.profileImageUrlString)
            }
            
            // comments count
            header.viewModel?.comments = self.comments
            // people count
            header.viewModel?.people = self.people
            
            return header
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

// MARK: - UICollectionViewDelegateFlowlayout

extension MeetDetailController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 {
            return CGSize(width: view.frame.width, height: 240)
            
        } else {
            
            // Get the view for the first header
            let indexPath = IndexPath(row: 0, section: section)
            let headerView = self.collectionView(
                collectionView,
                viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                at: indexPath)
            // Use this view to calculate the optimal size based on the collection view's width
            return headerView.systemLayoutSizeFitting(
                CGSize(
                    width: collectionView.frame.width,
                    height: UIView.layoutFittingExpandedSize.height
                ),
                withHorizontalFittingPriority: .required, // Width is fixed
                verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
        }
    }

}
 
// MARK: - CommentSectionHeaderDelegate

extension MeetDetailController: CommentSectionHeaderDelegate {
    func didTapAttendButton(_ header: CommentSectionHeader) {
        let controller = AttendMeetController()
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
}

// MARK: - CommentInputAccessoryViewDelegate

extension MeetDetailController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        // 拿目前user
        guard let tabBarController = tabBarController as? MainTabController else { return }
        guard let currentUser = tabBarController.user else { return }
        
        showLoader(true)
        
        CommentService.uploadMeetComment(
            meetId: meet.meetId,
            user: currentUser,
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
            
            // 通知被留言的人
        }
    }
}
