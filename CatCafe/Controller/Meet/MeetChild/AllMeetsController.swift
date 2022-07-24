//
//  AllMeetsController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit
import Firebase

class AllMeetsController: BaseMeetChildController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMeets()
    }
    
    private func fetchMeets() {
        MeetService.fetchMeets { [weak self] meets in
            guard let self = self else { return }
            
            // 過濾出封鎖名單以外的 meets
            // 過濾出還沒過期的 meets
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredMeets = meets.filter {
                !currentUser.blockedUsers.contains($0.ownerUid) &&
                ($0.timestamp.seconds > Timestamp(date: Date.now).seconds ? true : false)
            }
            
            self.meets = filteredMeets
            
            if filteredMeets.isEmpty {
                DispatchQueue.main.async {
                    self.showEmptyStateView(with: "目前無人發佈聚會，快去舉辦吧！😀", in: self.view)
                }
            } else {
                self.hideEmptyStateView(in: self.view)
            }
            
            self.checkIfCurrentUserLikedMeets()
            self.fetchMeetsCommentCount()
            
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc override func handleRefresh() {
        fetchMeets()
    }

}
