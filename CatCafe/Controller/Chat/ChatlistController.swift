//
//  ConversationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import Foundation
import UIKit

let id = "cell"

class ChatlistController: UIViewController {
    
    let tableView = UITableView()
    private lazy var newMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemBrown
        button.tintColor = .white
        button.imageView?.setDimensions(height: 24, width: 24)
        button.layer.cornerRadius = 56 / 2
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: id)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        // style
        view.backgroundColor = .white
        
        configureNavigationBar(withTitle: "Messages",
                               prefersLargeTitles: false,
                               shouldHideUnderline: true,
                               interfaceStyle: .light)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(showProfile)
        )
        
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
    
        // layout
        view.addSubview(tableView)
        view.addSubview(newMessageButton)
        tableView.frame = view.bounds
        newMessageButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                right: view.rightAnchor,
                                paddingBottom: 16,
                                paddingRight: 24)
        newMessageButton.setDimensions(height: 56, width: 56)
        
    }
    
    @objc func showProfile() {
        
    }
    
    @objc func showNewMessage() {
        let controller = NewMessageController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ChatlistController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? UserCell
        else { return UITableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

// MARK: - NewMessageControllerDelegate
extension ChatlistController: NewMessageControllerDelegate {
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User) {
        
        guard let currentUser = UserService.shared.currentUser else {
            print("DEBUG: Not getting current user")
            return
        }
        let chatId = startChat(user1: currentUser, user2: user)
        print("DEBUG: Start chatting chatroom id is ", chatId)
        
//        let controller = ChatController(user: user)
//        self.navigationController?.pushViewController(controller, animated: true)
    }
}
