//
//  MyAttendController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit

class MyAttendController: BaseMeetChildController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUserAttendMeets()
    }
    
    private func fetchCurrentUserAttendMeets() {
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

    @objc override func handleRefresh() {
        fetchCurrentUserAttendMeets()
    }
    
}
