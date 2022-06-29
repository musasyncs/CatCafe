//
//  ChatController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import UIKit

class ChatController: UIViewController {
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()
    
    // MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLeftBarButton()
        configureCustomTitle()
        configureMessageCollectionView()
    }
    
    // MARK: - Configurations
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Back02")?
                    .withTintColor(.black)
                    .withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(backButtonPressed)
            )
        ]
    }
    
    private func configureCustomTitle() {
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)

        titleLabel.text = recipientName
    }
    
    private func configureMessageCollectionView() {
        
    }
    
    // MARK: - Load Chats
    
    // MARK: - Insert Messages
    
    // MARK: - Actions
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
}
