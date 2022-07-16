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
        MeetService.fetchCurrentUserAttendMeets { meets in
            
            // 過濾出封鎖名單以外的 meets
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredMeets = meets.filter { !currentUser.blockedUsers.contains($0.ownerUid) }
            
            self.meets = filteredMeets
            self.checkIfCurrentUserLikedMeets()
            self.fetchMeetsCommentCount()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    @objc override func handleRefresh() {
        fetchCurrentUserAttendMeets()
    }
    
}
