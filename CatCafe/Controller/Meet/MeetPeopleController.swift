//
//  MeetPeopleController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/24.
//

import UIKit

class MeetPeopleViewController: UIViewController {
    
    private let meet: Meet
    private var hasAnimated = false
        
    private var people = [Person]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - View
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: SnappyFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(SnappyCell.self, forCellWithReuseIdentifier: SnappyCell.identifier)
        return collectionView
    }()
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let briefInfoView = BriefInfoView()
    private let leaveButton = makeTitleButton(
        withText: "離開",
        font: .systemFont(ofSize: 15, weight: .regular),
        kern: 1,
        foregroundColor: .white,
        backgroundColor: .clear,
        insets: .init(top: 8, left: 24, bottom: 8, right: 24),
        cornerRadius: 8, borderWidth: 2,
        borderColor: .white
    )
    
    // MARK: - Initializer
    init(meet: Meet) {
        self.meet = meet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLeaveButton()
        setupVisualEffectView()
        briefInfoView.layer.cornerRadius = 8
    
        fetchPeople()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAnimated {
            view.backgroundColor = .black.withAlphaComponent(0)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = .black.withAlphaComponent(0.6)
                self.view.layoutIfNeeded()
                self.hasAnimated = true
            })
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.centerY(inView: view)
        collectionView.setHeight(ScreenSize.height * 0.6)
        collectionView.anchor(left: view.leftAnchor, right: view.rightAnchor)
    }
    
    private func setupLeaveButton() {
        leaveButton.addTarget(self, action: #selector(handleLeave), for: .touchUpInside)
        view.addSubview(leaveButton)
        leaveButton.centerX(inView: view)
        leaveButton.anchor(bottom: view.bottomAnchor, paddingBottom: 64)
    }
    
    private func setupVisualEffectView() {
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBriefView)))
        visualEffectView.alpha = 0
        view.addSubview(visualEffectView)
        visualEffectView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
    }

    // MARK: - Helper
    private func dismissBriefInfoVC(person: Person?) {
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0
            self.briefInfoView.alpha = 0
            self.briefInfoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            
            self.briefInfoView.removeFromSuperview()
            guard let uid = person?.uid else { return }

            UserService.shared.fetchUserBy(uid: uid) { [weak self] user in
                guard let self = self else { return }
                let controller = ProfileController(user: user)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    // MARK: - API
    private func fetchPeople() {
        MeetService.fetchPeople(forMeet: meet.meetId) { [weak self] people in
            guard let self = self else { return }
            
            // 過濾出封鎖名單以外的 people
            guard let currentUser = UserService.shared.currentUser else { return }
            let filteredPeople = people.filter { !currentUser.blockedUsers.contains($0.uid) }
            
            self.people = filteredPeople
        }
    }
    
    // MARK: - Action
    @objc func dismissBriefView() {
        dismissBriefInfoVC(person: nil)
    }
    
    @objc func handleLeave() {
        dismiss(animated: false)
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MeetPeopleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SnappyCell.identifier,
            for: indexPath
        ) as? SnappyCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.person = people[indexPath.item]
        return cell
    }
    
}

// MARK: - SnappyCellDelegate (long press)
extension MeetPeopleViewController: SnappyCellDelegate {
    
    func presentInfoView(withPerson person: Person) {
        briefInfoView.person = person
        briefInfoView.delegate = self
        briefInfoView.forLongPressView()
        briefInfoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        briefInfoView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0.7
            self.briefInfoView.transform = .identity
            self.briefInfoView.alpha = 1
        }
        
        view.addSubview(briefInfoView)
        briefInfoView.setDimensions(height: 350, width: view.frame.width - 64)
        briefInfoView.center(inView: view)
    }
}

// MARK: - BriefInfoViewDelegate
extension MeetPeopleViewController: BriefInfoViewDelegate {
    func dismissInfoView(withPerson person: Person?) {
        dismissBriefInfoVC(person: person)
    }
}
