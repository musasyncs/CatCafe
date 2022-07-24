//
//  MyArrangeController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/23.
//

import UIKit
import Firebase

class MyArrangeController: BaseMeetChildController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.meets.isEmpty {
            DispatchQueue.main.async {
                self.showEmptyStateView(with: "您目前沒有發佈聚會，快去舉辦吧！😀", in: self.view)
            }
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyArrangedMeet()
    }
    
    private func fetchMyArrangedMeet() {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        MeetService.fetchMeets(forUser: currentUid) { [weak self] meets in
            guard let self = self else { return }
            
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
