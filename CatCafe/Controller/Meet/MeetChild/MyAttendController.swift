//
//  MyAttendController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit

class MyAttendController: BaseMeetChildController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUserAttendMeets()
    }
    
    private func fetchCurrentUserAttendMeets() {
        MeetService.fetchCurrentUserAttendMeets { [weak self] meets in
            guard let self = self else { return }
            
            // 過濾出封鎖名單以外的 meets
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredMeets = meets.filter { !currentUser.blockedUsers.contains($0.ownerUid) }
            self.meets = filteredMeets
            
            if filteredMeets.isEmpty {
                DispatchQueue.main.async {
                    self.showEmptyStateView(with: "您目前沒有報名聚會，快去報名吧！😀", in: self.view)
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
        fetchCurrentUserAttendMeets()
    }
    
}
