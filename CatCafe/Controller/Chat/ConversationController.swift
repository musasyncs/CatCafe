//
//  ConversationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import Foundation
import UIKit

let id = "cell"

class ConversationController: UIViewController {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: id)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        // style
        view.backgroundColor = .white
        
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(showProfile)
        )
        
        tableView.rowHeight = 80
        
        // layout
        tableView.backgroundColor = .systemPink
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    @objc func showProfile() {
        
    }
}

extension ConversationController: UITableViewDataSource, UITableViewDelegate {
    
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
