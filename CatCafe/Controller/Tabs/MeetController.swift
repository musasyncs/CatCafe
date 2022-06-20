//
//  MeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

class MeetController: UIViewController {
    
    lazy var arrangeMeetButtonItem = UIBarButtonItem(title: "舉辦聚會",
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(arrangeMeetTapped))
    lazy var allButton = BorderButton(text: "全部")
    lazy var myArrangedButton = BorderButton(text: "我發起的")
    lazy var myAttendButton = BorderButton(text: "我報名的")
    lazy var stackView = UIStackView(arrangedSubviews: [allButton, myArrangedButton, myAttendButton])
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MeetCell.self, forCellWithReuseIdentifier: MeetCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style
        view.backgroundColor = .white
        setupArrangeMeetButton()
        
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              left: view.leftAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor,
                              paddingTop: 60)
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         paddingTop: 8,
                         paddingLeft: 8)
    }
    
    // MARK: - Helper
    
    func setupArrangeMeetButton() {
        navigationItem.leftBarButtonItem = arrangeMeetButtonItem
    }
    
    // MARK: - Action
    
    @objc func arrangeMeetTapped() {
       print("DEBUG: Arrange meet")
    }
    
}

extension MeetController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MeetCell.identifier,
            for: indexPath ) as? MeetCell
        else { return UICollectionViewCell() }
         
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MeetController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = view.frame.width - 16
        return CGSize(width: width, height: 150)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}

final class MeetCell: UICollectionViewCell {
    
//    var viewModel: ? {
//        didSet {
//            guard let viewModel = viewModel else { return }
//
//        }
//    }
    
    private let meetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cutecat")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let titleLabel = UILabel()
    
    let timeTitleLabel = UILabel()
    let timeLabel = UILabel()
    lazy var timeStackView = UIStackView(arrangedSubviews: [timeTitleLabel, timeLabel])
    
    let placeTitleLabel = UILabel()
    let placeLabel = UILabel()
    lazy var placeStackView = UIStackView(arrangedSubviews: [placeTitleLabel, placeLabel])
    
    private let hostProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cutecat")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24 / 2
        return imageView
    }()
    let hostnameLabel = UILabel()
    let infoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // setup
        titleLabel.text = "春Land"
        timeTitleLabel.text = "時間"
        timeLabel.text = "06/25 19:00"
        placeTitleLabel.text = "地點"
        placeLabel.text = "Legacy Taipei"
        hostnameLabel.text = "阿布"
        infoLabel.text = "5人報名 | 1則留言"
        
        // style
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
        
        titleLabel.font = .notoMedium(size: 15)
        timeTitleLabel.font = .notoRegular(size: 10)
        timeTitleLabel.textColor = .systemGray
        timeLabel.font = .notoMedium(size: 11)
        placeTitleLabel.font = .notoRegular(size: 10)
        placeTitleLabel.textColor = .systemGray
        placeLabel.font = .notoMedium(size: 11)
        
        timeStackView.axis = .horizontal
        timeStackView.alignment = .center
        timeStackView.spacing = 8
        
        placeStackView.axis = .horizontal
        placeStackView.alignment = .center
        placeStackView.spacing = 8
        
        hostnameLabel.font = .notoRegular(size: 11)
        infoLabel.font = .notoRegular(size: 12)
        infoLabel.textColor = .systemGray
        
        // layout
        [meetImageView,
         titleLabel,
         timeStackView,
         placeStackView,
         hostProfileImageView,
         hostnameLabel,
         infoLabel].forEach {
            addSubview($0)
        }
        
        meetImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        meetImageView.setDimensions(height: 112, width: 112)
        
        titleLabel.anchor(top: meetImageView.topAnchor,
                          left: meetImageView.rightAnchor, paddingLeft: 8)
        timeStackView.anchor(top: titleLabel.bottomAnchor,
                             left: meetImageView.rightAnchor,
                             paddingTop: 8,
                             paddingLeft: 8)
        placeStackView.anchor(top: timeStackView.bottomAnchor,
                              left: meetImageView.rightAnchor,
                              paddingTop: 8,
                              paddingLeft: 8)
        hostProfileImageView.anchor(top: placeStackView.bottomAnchor,
                                    left: placeStackView.leftAnchor,
                                    paddingTop: 8)
        hostProfileImageView.setDimensions(height: 24, width: 24)
        hostnameLabel.centerY(inView: hostProfileImageView,
                              leftAnchor: hostProfileImageView.rightAnchor,
                              paddingLeft: 8)
        infoLabel.anchor(top: hostnameLabel.bottomAnchor, right: rightAnchor, paddingRight: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
