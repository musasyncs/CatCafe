//
//  MeetDetailController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

class MeetDetailController: UIViewController {
    
    private var meet: Meet {
        didSet {
            collectionView.reloadData()
        }
    }
    private var comments = [Comment]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: StretchyHeaderLayout())
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
        return collectionView
    }()
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let inputView = CommentInputAccessoryView(frame: frame)
        inputView.delegate = self
        return inputView
    }()
    
    override var inputAccessoryView: UIView? { return commentInputView }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var backButton = makeIconButton(imagename: "Icons_24px_Close",
                                    imageColor: .white,
                                    imageWidth: 24, imageHeight: 24,
                                    backgroundColor: UIColor(white: 0.5, alpha: 0.7),
                                    cornerRadius: 40 / 2)
        
    // MARK: - Life Cycle
        
    init(meet: Meet) {
        self.meet = meet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.layer.cornerRadius = 40 / 2
        backButton.clipsToBounds = true
        
        view.addSubview(collectionView)
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.leftAnchor, paddingLeft: 24)
        collectionView.anchor(top: view.topAnchor,
                              left: view.leftAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              right: view.rightAnchor,
                              paddingBottom: 45)
        backButton.setDimensions(height: 40, width: 40)
        
        fetchMeetWithMeetId()
        checkIfCurrentUserLikedMeet()
        checkIfCurrentUserAttendedMeet()
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

    func fetchMeetWithMeetId() {
        MeetService.fetchMeet(withMeetId: meet.meetId) { meet in
            self.meet.likes = meet.likes
        }
    }
    
    func checkIfCurrentUserLikedMeet() {
        MeetService.checkIfCurrentUserLikedMeet(meet: meet) { isLiked in
            self.meet.isLiked = isLiked
        }
    }

    func checkIfCurrentUserAttendedMeet() {
        MeetService.checkIfCurrentUserAttendedMeet(meet: meet) { isAttended in
            self.meet.isAttended = isAttended
        }
    }
    
    func fetchComments() {
        CommentService.fetchMeetComments(forMeet: meet.meetId) { comments in
            self.comments = comments
        }
    }
    
    // MARK: - Action
    
    @objc func goBack() {
        dismiss(animated: false)
    }

}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension MeetDetailController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return comments.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommentCell.identifier,
            for: indexPath) as? CommentCell
        else { return UICollectionViewCell() }
        
        let comment = comments[indexPath.item]
        cell.viewModel = CommentViewModel(comment: comment)
        
        UserService.shared.fetchUserBy(uid: comment.uid) { user in
            cell.viewModel?.username = user.username
            cell.viewModel?.profileImageUrl = URL(string: user.profileImageUrlString)
        }
        return cell
    }
    
    func collectionView(
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
                        
            UserService.shared.fetchUserBy(uid: meet.ownerUid) { user in
                header.viewModel?.ownerUsername = user.username
                header.viewModel?.ownerImageUrl = URL(string: user.profileImageUrlString)
            }
            
            // comments count
            header.viewModel?.comments = self.comments
                                
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

// MARK: - UICollectionViewDelegateFlowlayout

extension MeetDetailController: UICollectionViewDelegateFlowLayout {
    
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
                
        let approximateWidthOfTextArea = UIScreen.width - 8 - 24 - 8 - 8
        let approximateSize = CGSize(width: approximateWidthOfTextArea, height: 100)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)]
        
        let estimatedHeight: CGFloat = 8 + (32)
        
        // Get an estimation of the height of cell based on comments[indexPath.item].comment
        let estimatedFrame = String(describing: comments[indexPath.item].comment).boundingRect(
            with: approximateSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil)
        return CGSize(
            width: view.frame.width,
            height: estimatedFrame.height + estimatedHeight
        )
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
                CGSize(width: collectionView.frame.width,
                       height: UIView.layoutFittingExpandedSize.height),
                withHorizontalFittingPriority: .required, // Width is fixed
                verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
        }
    }

}
 
// MARK: - CommentSectionHeaderDelegate

extension MeetDetailController: CommentSectionHeaderDelegate {
    func didTapSeeAllPeopleButton(_ header: CommentSectionHeader) {
        let controller = MeetPeopleViewController(meet: meet)
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
    
    func didTapAttendButton(_ header: CommentSectionHeader) {
        let controller = AttendMeetController(meet: meet)
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
}

// MARK: - CommentInputAccessoryViewDelegate

extension MeetDetailController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        UserService.shared.fetchUserBy(uid: currentUid, completion: { currentUser in
            
            CCProgressHUD.show()
            CommentService.uploadMeetComment(
                meetId: self.meet.meetId,
                user: currentUser,
                commentType: 0,
                mediaUrlString: "",
                comment: comment
            ) { error in
                CCProgressHUD.dismiss()
                
                if let error = error {
                    print("DEBUG: Failed to upload comment with error \(error.localizedDescription)")
                    return
                }
                
                inputView.clearCommentTextView()
                
                // 通知被留言的人
            }
            
        })
                                
    }
}
