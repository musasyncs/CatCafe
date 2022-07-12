//
//  MyArrangeController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit

class MyArrangeController: BaseMeetChildController {
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyArrangedMeet()
    }
    
    private func fetchMyArrangedMeet() {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        MeetService.fetchMeets(forUser: currentUid) { meets in
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

    @objc override func handleRefresh() {
        fetchMyArrangedMeet()
    }
    
}
