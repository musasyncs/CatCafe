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
    lazy var allButton = makeTitleButton(withText: "全部",
                                         font: .notoRegular(size: 11),
                                         insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                         cornerRadius: 8,
                                         borderWidth: 1,
                                         borderColor: .systemBrown)
    lazy var myArrangedButton = makeTitleButton(withText: "我發起的",
                                                font: .notoRegular(size: 11),
                                                insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                                cornerRadius: 8,
                                                borderWidth: 1,
                                                borderColor: .systemBrown)
    lazy var myAttendButton = makeTitleButton(withText: "我報名的",
                                              font: .notoRegular(size: 11),
                                              insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                              cornerRadius: 8,
                                              borderWidth: 1,
                                              borderColor: .systemBrown)
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
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         paddingTop: 8,
                         paddingLeft: 8)
        view.addSubview(collectionView)
        collectionView.anchor(top: stackView.bottomAnchor,
                              left: view.leftAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor,
                              paddingTop: 8)
    }
    
    // MARK: - Helper
    
    func setupArrangeMeetButton() {
        arrangeMeetButon.addTarget(self, action: #selector(arrangeMeetTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = arrangeMeetButtonItem
    }
    
    // MARK: - Action
    
    @objc func arrangeMeetTapped() {
        let controller = UploadMeetPicController()
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
}

extension MeetController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MeetDetailController(collectionViewLayout: StretchyHeaderLayout())
        
        navigationController?.pushViewController(controller, animated: true)
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
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension MeetCell {
    fileprivate func setup() {
        titleLabel.text = "春Land"
        timeTitleLabel.text = "時間"
        timeLabel.text = "06/25 19:00"
        placeTitleLabel.text = "地點"
        placeLabel.text = "Legacy Taipei"
        hostnameLabel.text = "阿布"
        infoLabel.text = "5人報名 | 1則留言"
    }
    
    fileprivate func style() {
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
    }
    
    fileprivate func layout() {
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
        infoLabel.anchor(top: hostnameLabel.bottomAnchor, right: rightAnchor, paddingRight: 8)
    }
}
