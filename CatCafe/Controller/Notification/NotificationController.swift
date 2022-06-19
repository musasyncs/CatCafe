//
//  NotificationController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import UIKit

class NotificationController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        setupBarButtonItem()
        setupTableView()
    }
    
    // MARK: - Helpers
    
    func setupBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
    }
    
    func setupTableView() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: false, completion: nil)
    }
}

extension NotificationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.identifier,
            for: indexPath) as? NotificationCell
        else { return UITableViewCell() }
        return cell
    }
}

final class NotificationCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48 / 2
        return imageView
    }()
    
    private let infoLabel: UILabel = {
       let label = UILabel()
        label.font = .notoMedium(size: 14)
        label.text = "riho123"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(infoLabel)
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        infoLabel.centerY(inView: profileImageView,
                          leftAnchor: profileImageView.rightAnchor,
                          paddingLeft: 8)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
