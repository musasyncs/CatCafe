//
//  BaseMeetChildController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/4.
//

import UIKit

class BaseMeetChildController: CCDataLoadingController {
    
    var meets = [Meet]() {
        didSet {
            collectionView.reloadData()
        }
    }

    lazy var collectionView: UICollectionView = {
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
        view.backgroundColor = .white
        setupCollectionView()
        setupPullToRefresh()
        setupUpdateMeetFeedObserver()
    }
    
    func checkIfCurrentUserLikedMeets() {
        meets.forEach { [weak self] meet in
            guard let self = self else { return }
            MeetService.checkIfCurrentUserLikedMeet(meet: meet) { isLiked in
                if let index = self.meets.firstIndex(where: { $0.meetId == meet.meetId }) {
                    self.meets[index].isLiked = isLiked
                }
            }
        }
    }
    
    func fetchMeetsCommentCount() {
        meets.forEach { [weak self] meet in
            guard let self = self else { return }
            CommentService.shared.fetchMeetComments(forMeet: meet.meetId) { comments in
                if let index = self.meets.firstIndex(where: { $0.meetId == meet.meetId }) {
                    self.meets[index].commentCount = comments.count
                }
            }
        }
    }
    
    @objc func handleRefresh() {}
    
}

extension BaseMeetChildController {
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.fillSuperView()
    }
    
    func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    func setupUpdateMeetFeedObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: CCConstant.NotificationName.updateMeetFeed,
            object: nil
        )
    }
    
}

// MARK: - MeetCellDelegate
extension BaseMeetChildController: MeetCellDelegate {
    
    func cell(_ cell: MeetCell, didLike meet: Meet) {
        cell.viewModel?.meet.isLiked.toggle()
        
        if meet.isLiked {
            MeetService.unlikeMeet(meet: meet) { likeCount in
                cell.viewModel?.meet.likes = likeCount
            }
        } else {
            MeetService.likeMeet(meet: meet) { likeCount in
                cell.viewModel?.meet.likes = likeCount
            }
        }
        
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension BaseMeetChildController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meets.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MeetCell.identifier,
            for: indexPath ) as? MeetCell
        else { return UICollectionViewCell() }
        cell.delegate = self
        cell.viewModel = MeetViewModel(meet: meets[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MeetDetailController(meet: meets[indexPath.item])
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BaseMeetChildController: UICollectionViewDelegateFlowLayout {
    
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
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 16
    }
}
