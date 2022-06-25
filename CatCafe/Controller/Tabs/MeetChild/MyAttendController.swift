//
//  MyAttendController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit

class MyAttendController: UIViewController {
    
    var meets = [Meet]() {
        didSet {
            collectionView.reloadData()
        }
    }

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MeetCell.self, forCellWithReuseIdentifier: MeetCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
    
        fetchCurrentUserAttendMeets()
    }
    
    // MARK: - API
    
    func fetchCurrentUserAttendMeets() {
        MeetService.fetchCurrentUserAttendMeets { meets in
            self.meets = meets
            self.checkIfCurrentUserLikedMeets()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func checkIfCurrentUserLikedMeets() {
        self.meets.forEach { meet in
            MeetService.checkIfCurrentUserLikedMeet(meet: meet) { isLiked in
                if let index = self.meets.firstIndex(where: { $0.meetId == meet.meetId }) {
                    self.meets[index].isLiked = isLiked
                }
            }
        }
    }

    // MARK: - Action
    
    @objc func handleRefresh() {
        fetchCurrentUserAttendMeets()
    }
    
}

extension MyAttendController {
    
    func setup() {
        // setup pull to refresh
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
        
        // setup Update Meet Feed Observer
        addUpdateMeetFeedObserver()
    }
    
    func style() {
        view.backgroundColor = .white
    }
    
    func layout() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor,
                              left: view.leftAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor)
    }
    
    func addUpdateMeetFeedObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: CCConstant.NotificationName.updateMeetFeed,
            object: nil
        )
    }

}

// MARK: - MeetCellDelegate

extension MyAttendController: MeetCellDelegate {
    
    func cell(_ cell: MeetCell, didLike meet: Meet) {
        cell.viewModel?.meet.isLiked.toggle()
        
        if meet.isLiked {
            MeetService.unlikeMeet(meet: meet) { _ in
                cell.viewModel?.meet.likes = meet.likes - 1
            }
        } else {
            MeetService.likeMeet(meet: meet) { _ in
                cell.viewModel?.meet.likes = meet.likes + 1
                
                // 發like通知給對方 Optional
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MyAttendController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meets.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MeetCell.identifier,
            for: indexPath ) as? MeetCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let meet = meets[indexPath.item]
        cell.viewModel = MeetViewModel(meet: meet)
        
        UserService.fetchUserBy(uid: meet.ownerUid) { user in
            cell.viewModel?.ownerUsername = user.username
            cell.viewModel?.ownerImageUrl = URL(string: user.profileImageUrlString)
        }
        
        // meet comments count
        CommentService.fetchMeetComments(forMeet: meet.meetId) { comments in
            cell.viewModel?.comments = comments
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MeetDetailController(meet: meets[indexPath.item])
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MyAttendController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = view.frame.width - 16
        return CGSize(width: width, height: 170)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 16
        }
}
