//
//  ConversationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import Foundation
import UIKit

class ConversationController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(showProfile)
        )
    }
    
    @objc func showProfile() {
        
    }
}
