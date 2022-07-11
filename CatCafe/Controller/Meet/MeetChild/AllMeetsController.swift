//
//  AllMeetsController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit

class AllMeetsController: BaseMeetChildController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    // MARK: - Action
    @objc override func handleRefresh() {
        fetchMeets()
    }

}
