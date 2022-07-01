//
//  InfoCollectionViewCell.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            usernameTextField.text      = user?.username
            fullnameTextField.text      = user?.fullname
            emailTextField.text         = user?.email
        }
    }
    
    let usernameLabel     = ProfileLabel(title: "帳號")
    let fullnameLabel     = ProfileLabel(title: "全名")
    let emailLabel        = ProfileLabel(title: "email")
    let usernameTextField = ProfileTextField(placeholder: "帳號")
    let fullnameTextField = ProfileTextField(placeholder: "全名")
    let emailTextField    = ProfileTextField(placeholder: "email")
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        // setup
        let pairs = [
            [usernameLabel, usernameTextField],
            [fullnameLabel, fullnameTextField],
            [emailLabel, emailTextField]
        ]
        let pairSVs = pairs.map { (pair) -> UIStackView in
            guard let label = pair.first as? UILabel,
                  let textField = pair.last as? UITextField else { return UIStackView() }
            let pairSV = UIStackView(arrangedSubviews: [label, textField])
            pairSV.axis = .vertical
            pairSV.spacing = 5
            textField.textColor = .black
            textField.anchor(height: 45)
            return pairSV
        }
        let stackView = UIStackView(arrangedSubviews: pairSVs)
        
        // style
        backgroundColor = .white
        stackView.axis = .vertical
        stackView.spacing = 15
        
        // layout
        addSubview(stackView)
        stackView.fillSuperView()
        usernameTextField.anchor(width: UIScreen.width - 80)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ProfileLabel
class ProfileLabel: UILabel {
    // 名字大標題使用
    init() {
        super.init(frame: .zero)
        font        = .systemFont(ofSize: 24, weight: .bold)
        textColor   = .black
    }
    
    // Cell的小標題使用
    init(title: String) {
        super.init(frame: .zero)
        text        = title
        textColor   = .darkGray
        font        = .systemFont(ofSize: 14)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ProfileTextField
class ProfileTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        borderStyle = .roundedRect
        self.placeholder = placeholder
        if placeholder == "email" {
            isUserInteractionEnabled = false
            backgroundColor = .rgb(red: 233, green: 233, blue: 233)
        } else {
            backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
