//
//  MeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

class MeetController: UIViewController {
        
    lazy var arrangeMeetButon = makeTitleButton(withText: "舉辦聚會", font: .notoRegular(size: 12))
    lazy var arrangeMeetButtonItem = UIBarButtonItem(customView: arrangeMeetButon)
    
    lazy var allButton = makeTitleButton(
        withText: "全部",
        font: .notoRegular(size: 11),
        foregroundColor: .systemBrown,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: .systemBrown
    )
    lazy var myArrangedButton = makeTitleButton(
        withText: "我發起的",
        font: .notoRegular(size: 11),
        foregroundColor: .systemBrown,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: .systemBrown
    )
    lazy var myAttendButton = makeTitleButton(
        withText: "我報名的",
        font: .notoRegular(size: 11),
        foregroundColor: .systemBrown,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: .systemBrown
    )
    lazy var stackView = UIStackView(arrangedSubviews: [allButton, myArrangedButton, myAttendButton])
    
    let containerVC = UIViewController()
    
    let allMeetsController = AllMeetsController()
    let myArrangeController = MyArrangeController()
    let myAttendController = MyAttendController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
        allButtonTapped()
    }
    
    // MARK: - Helpers
    
    private func setupButtons(
        button1fgColor: UIColor, button1bgColor: UIColor,
        button2fgColor: UIColor, button2bgColor: UIColor,
        button3fgColor: UIColor, button3bgColor: UIColor
    ) {
        let text1 = NSMutableAttributedString(
            string: "全部",
            attributes: [
                .font: UIFont.notoRegular(size: 11),
                .foregroundColor: button1fgColor,
                .kern: 1
            ])
        self.allButton.setAttributedTitle(text1, for: .normal)
        self.allButton.backgroundColor = button1bgColor
        
        let text2 = NSMutableAttributedString(
            string: "我發起的",
            attributes: [
                .font: UIFont.notoRegular(size: 11),
                .foregroundColor: button2fgColor,
                .kern: 1
            ])
        self.myArrangedButton.setAttributedTitle(text2, for: .normal)
        self.myArrangedButton.backgroundColor = button2bgColor
        
        let text3 = NSMutableAttributedString(
            string: "我報名的",
            attributes: [
                .font: UIFont.notoRegular(size: 11),
                .foregroundColor: button3fgColor,
                .kern: 1
            ])
        self.myAttendButton.setAttributedTitle(text3, for: .normal)
        self.myAttendButton.backgroundColor = button3bgColor
    }
    
    // MARK: - Action
    
    @objc func arrangeMeetTapped() {
        let controller = SelectMeetPicController()
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func allButtonTapped() {
        allMeetsController.view.isHidden = false
        myArrangeController.view.isHidden = true
        myAttendController.view.isHidden = true
        
        self.setupButtons(
            button1fgColor: .white, button1bgColor: .systemBrown,
            button2fgColor: .systemBrown, button2bgColor: .white,
            button3fgColor: .systemBrown, button3bgColor: .white
        )
    }
    
    @objc func myArrangedButtonTapped() {
        allMeetsController.view.isHidden = true
        myArrangeController.view.isHidden = false
        myAttendController.view.isHidden = true
        
        self.setupButtons(
            button1fgColor: .systemBrown, button1bgColor: .white,
            button2fgColor: .white, button2bgColor: .systemBrown,
            button3fgColor: .systemBrown, button3bgColor: .white
        )
    }
    
    @objc func myAttendButtonTapped() {
        allMeetsController.view.isHidden = true
        myArrangeController.view.isHidden = true
        myAttendController.view.isHidden = false
        
        self.setupButtons(
            button1fgColor: .systemBrown, button1bgColor: .white,
            button2fgColor: .systemBrown, button2bgColor: .white,
            button3fgColor: .white, button3bgColor: .systemBrown
        )
    }

}

extension MeetController {
    
    func setup() {
        arrangeMeetButon.addTarget(self, action: #selector(arrangeMeetTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = arrangeMeetButtonItem
        
        allButton.addTarget(self, action: #selector(allButtonTapped), for: .touchUpInside)
        myArrangedButton.addTarget(self, action: #selector(myArrangedButtonTapped), for: .touchUpInside)
        myAttendButton.addTarget(self, action: #selector(myAttendButtonTapped), for: .touchUpInside)
        
        addChild(allMeetsController)
        addChild(myArrangeController)
        addChild(myAttendController)
        didMove(toParent: allMeetsController)
        didMove(toParent: myArrangeController)
        didMove(toParent: myAttendController)
    }
    
    func style() {
        view.backgroundColor = .white
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
    }
    
    func layout() {
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         paddingTop: 8,
                         paddingLeft: 8)
        
        view.addSubview(allMeetsController.view)
        view.addSubview(myArrangeController.view)
        view.addSubview(myAttendController.view)
        allMeetsController.view.anchor(top: stackView.bottomAnchor,
                                       left: view.leftAnchor,
                                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                       right: view.rightAnchor)
        myArrangeController.view.anchor(top: stackView.bottomAnchor,
                        left: view.leftAnchor,
                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                        right: view.rightAnchor)
        myAttendController.view.anchor(top: stackView.bottomAnchor,
                        left: view.leftAnchor,
                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                        right: view.rightAnchor)
    }
}
