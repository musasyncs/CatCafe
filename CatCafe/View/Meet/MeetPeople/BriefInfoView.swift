//
//  BriefInfoView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/24.
//

import UIKit

protocol BriefInfoViewDelegate: AnyObject {
    func dismissInfoView(withPerson person: Person?)
}

class BriefInfoView: UIView {
    weak var delegate: BriefInfoViewDelegate?
    
    var person: Person? {
        didSet {
            guard let person = self.person else { return }
            
            UserService.fetchUserBy(uid: person.uid) { user in
                self.titleLabel.text = user.fullname
            }
            
            configureLabel(label: contactLabel, title: "聯絡方式", details: person.contact)
            configureLabel(label: remarksLabel, title: "想說的話", details: person.remarks)
        }
    }
    
    let topView = UIView()
    let titleLabel = UILabel()
    
    let contactLabel = UILabel()
    let remarksLabel = UILabel()
    
    lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        button.setTitle("查看個人頁面", for: .normal)
        button.backgroundColor = .systemBrown
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureLabel(label: UILabel, title: String, details: String) {
        let attributedText = NSMutableAttributedString(
            attributedString: NSAttributedString(
                string: "\(title):  ",
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13),
                    NSAttributedString.Key.foregroundColor: UIColor.systemBrown
                ]
            )
        )
        attributedText.append(NSAttributedString(
            string: "\(details)",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                NSAttributedString.Key.foregroundColor: UIColor.gray
            ]
        ))
        label.attributedText = attributedText
    }
    
    func forLongPressView() {
        topView.backgroundColor = .systemBrown
        topView.layer.cornerRadius = 5
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        addSubview(topView)
        topView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 50)
        topView.addSubview(titleLabel)
        titleLabel.center(inView: topView)
        
        addSubview(contactLabel)
        contactLabel.anchor(top: topView.bottomAnchor,
                            left: leftAnchor,
                            paddingTop: 16, paddingLeft: 16)
        addSubview(remarksLabel)
        remarksLabel.anchor(top: contactLabel.bottomAnchor,
                            left: leftAnchor,
                            paddingTop: 16,
                            paddingLeft: 16)
        
        addSubview(profileButton)
        profileButton.anchor(
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            paddingLeft: 16,
            paddingBottom: 16,
            paddingRight: 16,
            height: 36)
    }
    
    // MARK: - Action
 
    @objc func profileButtonTapped() {
        guard let person = self.person else { return }
        delegate?.dismissInfoView(withPerson: person)
    }

}
