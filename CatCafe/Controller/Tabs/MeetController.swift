//
//  MeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

class MeetController: UIViewController {
    
    var meets = [Meet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var arrangeMeetButon = makeTitleButton(withText: "舉辦聚會", font: .notoRegular(size: 12))
    lazy var arrangeMeetButtonItem = UIBarButtonItem(customView: arrangeMeetButon)
    lazy var allButton = makeTitleButton(withText: "全部",
                                         font: .notoRegular(size: 11),
                                         insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                         cornerRadius: 8,
                                         borderWidth: 1,
                                         borderColor: .systemBrown)
    lazy var myArrangedButton = makeTitleButton(withText: "我發起的",
                                                font: .notoRegular(size: 11),
                                                insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                                cornerRadius: 8,
                                                borderWidth: 1,
                                                borderColor: .systemBrown)
    lazy var myAttendButton = makeTitleButton(withText: "我報名的",
                                              font: .notoRegular(size: 11),
                                              insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                              cornerRadius: 8,
                                              borderWidth: 1,
                                              borderColor: .systemBrown)
    lazy var stackView = UIStackView(arrangedSubviews: [allButton, myArrangedButton, myAttendButton])
    
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
        
        setupUpdateMeetFeedObserver()
        fetchMeets()
    }
    
    // MARK: - API
    
    func fetchMeets() {
        MeetService.fetchMeets { meets in
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
    
    // MARK: - Helper
    
    func setup() {
        // setup pull to refresh
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    func style() {
        view.backgroundColor = .white
        setupArrangeMeetButton()
        
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
    }
    
    func layout() {
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         paddingTop: 8,
                         paddingLeft: 8)
        view.addSubview(collectionView)
        collectionView.anchor(top: stackView.bottomAnchor,
                              left: view.leftAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor,
                              paddingTop: 8)
    }
    
    func setupUpdateMeetFeedObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: CCConstant.NotificationName.updateMeetFeed,
            object: nil
        )
    }
    
    func setupArrangeMeetButton() {
        arrangeMeetButon.addTarget(self, action: #selector(arrangeMeetTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = arrangeMeetButtonItem
    }
    
    // MARK: - Action
    
    @objc func arrangeMeetTapped() {
        let controller = SelectMeetPicController()
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func handleRefresh() {
        meets.removeAll()
        fetchMeets()
    }
    
}

// MARK: - MeetCellDelegate

extension MeetController: MeetCellDelegate {
    
    func cell(_ cell: MeetCell, didLike meet: Meet) {
        cell.viewModel?.meet.isLiked.toggle()
        
        if meet.isLiked {
            
            MeetService.unlikeMeet(meet: meet) { _ in
                cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                cell.likeButton.tintColor = .black
                cell.viewModel?.meet.likes = meet.likes - 1
            }
        } else {
            MeetService.likeMeet(meet: meet) { _ in
                cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
                cell.likeButton.tintColor = .systemRed
                cell.viewModel?.meet.likes = meet.likes + 1
                
                // 發like通知給對方 Optional
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MeetController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        let meet = meets[indexPath.item]
        let controller = MeetDetailController(meet: meet)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MeetController: UICollectionViewDelegateFlowLayout {
    
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
