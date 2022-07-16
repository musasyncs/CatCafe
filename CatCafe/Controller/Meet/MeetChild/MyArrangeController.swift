//
//  MyArrangeController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit
import Firebase

class MyArrangeController: BaseMeetChildController {
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyArrangedMeet()
    }
    
    private func fetchMyArrangedMeet() {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        MeetService.fetchMeets(forUser: currentUid) { meets in
            
            // 過濾出還沒過期的 meets
            let filteredMeets = meets.filter {
                $0.timestamp.seconds > Timestamp(date: Date.now).seconds ? true : false
            }
            
            self.meets = filteredMeets
            self.checkIfCurrentUserLikedMeets()
            self.fetchMeetsCommentCount()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    @objc override func handleRefresh() {
        fetchMyArrangedMeet()
    }
    
}
