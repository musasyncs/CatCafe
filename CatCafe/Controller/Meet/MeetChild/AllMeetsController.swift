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
        MeetService.fetchMeets { meets in
            
            // 過濾出封鎖名單以外的 meets
            // 過濾出還沒過期的 meets
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredMeets = meets.filter {
                !currentUser.blockedUsers.contains($0.ownerUid) &&
                ($0.timestamp.seconds > Timestamp(date: Date.now).seconds ? true : false)
            }
            
            self.meets = filteredMeets
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

    @objc override func handleRefresh() {
        fetchMeets()
    }

}
