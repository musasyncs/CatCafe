//
//  MeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

class MeetController: UIViewController {
    
    // MARK: - View
    private lazy var arrangeMeetButon = makeTitleButton(
        withText: "舉辦聚會",
        font: .systemFont(ofSize: 12, weight: .regular),
        foregroundColor: .white,
        backgroundColor: .ccSecondary,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        cornerRadius: 8
    )
    private lazy var arrangeMeetButtonItem = UIBarButtonItem(customView: arrangeMeetButon)
    
    private lazy var allButton = makeTitleButton(
        withText: "全部",
        font: .systemFont(ofSize: 11, weight: .regular),
        foregroundColor: .ccPrimary,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: .ccPrimary
    )
    
    private lazy var myArrangedButton = makeTitleButton(
        withText: "我發起的",
        font: .systemFont(ofSize: 11, weight: .regular),
        foregroundColor: .ccPrimary,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: .ccPrimary
    )
    
    private lazy var myAttendButton = makeTitleButton(
        withText: "我報名的",
        font: .systemFont(ofSize: 11, weight: .regular),
        foregroundColor: .ccPrimary,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: .ccPrimary
    )
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [allButton, myArrangedButton, myAttendButton])
    
    private let containerVC = UIViewController()
    private let allMeetsController = AllMeetsController()
    private let myArrangeController = MyArrangeController()
    private let myAttendController = MyAttendController()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavButtons()
        setupStackView()
        setupChildController()
        allButtonTapped()
    }
    
    // MARK: - Helper
    // swiftlint:disable:next function_parameter_count
    private func setupButtons(
        button1fgColor: UIColor, button1bgColor: UIColor,
        button2fgColor: UIColor, button2bgColor: UIColor,
        button3fgColor: UIColor, button3bgColor: UIColor
    ) {
        let text1 = NSMutableAttributedString(
            string: "全部",
            attributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: button1fgColor,
                .kern: 1
            ])
        self.allButton.setAttributedTitle(text1, for: .normal)
        self.allButton.backgroundColor = button1bgColor
        
        let text2 = NSMutableAttributedString(
            string: "我發起的",
            attributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: button2fgColor,
                .kern: 1
            ])
        self.myArrangedButton.setAttributedTitle(text2, for: .normal)
        self.myArrangedButton.backgroundColor = button2bgColor
        
        let text3 = NSMutableAttributedString(
            string: "我報名的",
            attributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: button3fgColor,
                .kern: 1
            ])
        self.myAttendButton.setAttributedTitle(text3, for: .normal)
        self.myAttendButton.backgroundColor = button3bgColor
    }
    
    // MARK: - Action
    @objc func arrangeMeetTapped() {
        let controller = SelectMeetPicController()
        let navController = makeNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
    
    @objc func allButtonTapped() {
        allMeetsController.view.isHidden = false
        myArrangeController.view.isHidden = true
        myAttendController.view.isHidden = true
        
        self.setupButtons(
            button1fgColor: .white, button1bgColor: .ccPrimary,
            button2fgColor: .ccPrimary, button2bgColor: .white,
            button3fgColor: .ccPrimary, button3bgColor: .white
        )
    }
    
    @objc func myArrangedButtonTapped() {
        allMeetsController.view.isHidden = true
        myArrangeController.view.isHidden = false
        myAttendController.view.isHidden = true
        
        self.setupButtons(
            button1fgColor: .ccPrimary, button1bgColor: .white,
            button2fgColor: .white, button2bgColor: .ccPrimary,
            button3fgColor: .ccPrimary, button3bgColor: .white
        )
    }
    
    @objc func myAttendButtonTapped() {
        allMeetsController.view.isHidden = true
        myArrangeController.view.isHidden = true
        myAttendController.view.isHidden = false
        
        self.setupButtons(
            button1fgColor: .ccPrimary, button1bgColor: .white,
            button2fgColor: .ccPrimary, button2bgColor: .white,
            button3fgColor: .white, button3bgColor: .ccPrimary
        )
    }
    
}

extension MeetController {
    
    private func setupNavButtons() {
        arrangeMeetButon.addTarget(self, action: #selector(arrangeMeetTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = arrangeMeetButtonItem
        
        allButton.addTarget(self, action: #selector(allButtonTapped), for: .touchUpInside)
        
        myArrangedButton.addTarget(self, action: #selector(myArrangedButtonTapped), for: .touchUpInside)
        myAttendButton.addTarget(self, action: #selector(myAttendButtonTapped), for: .touchUpInside)
    }
    
    private func setupStackView() {
        buttonStackView.backgroundColor = .white
        buttonStackView.alignment = .center
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillProportionally
        view.addSubview(buttonStackView)
        buttonStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               left: view.leftAnchor,
                               paddingTop: 8,
                               paddingLeft: 16)
    }
    
    private func setupChildController() {
        addChild(allMeetsController)
        addChild(myArrangeController)
        addChild(myAttendController)
        didMove(toParent: allMeetsController)
        didMove(toParent: myArrangeController)
        didMove(toParent: myAttendController)
        view.addSubviews(allMeetsController.view, myArrangeController.view, myAttendController.view)
        
        allMeetsController.view.anchor(top: buttonStackView.bottomAnchor,
                                       left: view.leftAnchor,
                                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                       right: view.rightAnchor,
                                       paddingTop: 8)
        myArrangeController.view.anchor(top: buttonStackView.bottomAnchor,
                                        left: view.leftAnchor,
                                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                        right: view.rightAnchor,
                                        paddingTop: 8)
        myAttendController.view.anchor(top: buttonStackView.bottomAnchor,
                                       left: view.leftAnchor,
                                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                       right: view.rightAnchor,
                                       paddingTop: 8)
    }
    
}
