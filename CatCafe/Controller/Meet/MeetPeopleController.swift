//
//  MeetPeopleController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/24.
//

import UIKit
import SDWebImage

class MeetPeopleViewController: UIViewController {
    
    let meet: Meet
        
    var people = [Person]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: SnappyFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(SnappyCell.self, forCellWithReuseIdentifier: SnappyCell.identifier)
        return collectionView
    }()
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let briefInfoView = BriefInfoView()
    let leaveButton = makeTitleButton(
        withText: "離開",
        font: .systemFont(ofSize: 15, weight: .regular),
        kern: 1,
        foregroundColor: .white,
        backgroundColor: .clear,
        insets: .init(top: 8, left: 24, bottom: 8, right: 24),
        cornerRadius: 8, borderWidth: 2,
        borderColor: .white
    )
    
    // MARK: - Life Cycle
    
    init(meet: Meet) {
        self.meet = meet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaveButton.addTarget(self, action: #selector(handleLeave), for: .touchUpInside)
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBriefView)))
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        visualEffectView.alpha = 0
        briefInfoView.layer.cornerRadius = 8
        
        view.addSubview(collectionView)
        view.addSubview(leaveButton)
        view.addSubview(visualEffectView)
        
        visualEffectView.anchor(top: view.topAnchor,
                                left: view.leftAnchor,
                                bottom: view.bottomAnchor,
                                right: view.rightAnchor)
        
        collectionView.centerY(inView: view)
        collectionView.setHeight(UIScreen.height * 0.6)
        collectionView.anchor(left: view.leftAnchor, right: view.rightAnchor)
        
        leaveButton.centerX(inView: view)
        leaveButton.anchor(bottom: view.bottomAnchor, paddingBottom: 64)
        
        fetchPeople()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .black.withAlphaComponent(0)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = .black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Helpers
    
    func dismissBriefInfoVC(person: Person?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.alpha = 0
            self.briefInfoView.alpha = 0
            self.briefInfoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.briefInfoView.removeFromSuperview()            
            
            // go to profile
            guard let person = person else { return }
            print("DEBUG: \(person.uid)")
        }
    }
    
    // MARK: - API
    
    private func fetchPeople() {
        MeetService.fetchPeople(forMeet: meet.meetId) { people in
            self.people = people
        }
    }
    
    // MARK: - Action

    @objc func dismissBriefView() {
        dismissBriefInfoVC(person: nil)
    }
    
    @objc func handleLeave() {
        dismiss(animated: true)
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
//        let person = people[indexPath.item]
        // go to profile
      
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
            self.visualEffectView.alpha = 1
            self.briefInfoView.transform = .identity
            self.briefInfoView.alpha = 1
        }
        
        view.addSubview(briefInfoView)
        briefInfoView.setDimensions(height: 350, width: view.frame.width - 64)
        briefInfoView.centerX(inView: view)
        briefInfoView.centerY(inView: view)
    }
}

// MARK: - BriefInfoViewDelegate

extension MeetPeopleViewController: BriefInfoViewDelegate {
    func dismissInfoView(withPerson person: Person?) {
        dismissBriefInfoVC(person: person)
    }
}
