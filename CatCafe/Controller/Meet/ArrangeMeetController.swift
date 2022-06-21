//
//  ArrangeMeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

class ArrangeMeetController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            imageHeaderView.picView.placedImageView.image = selectedImage
        }
    }
    var chosenDate: Date?
    var meetTitleText: String? {
        titleTileView.textField.text
    }
    var meetPlaceText: String? {
        placeTileView.textField.text
    }
    var meetDescription: String? {
        descriptionTileView.textField.text
    }
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let imageHeaderView = ImageHeaderView()
    let meetTimeTileView = MeetTimeTileView()
    let titleTileView = TileView(
        title: "聚會主題",
        placeholder: "開啟你想討論的話題，或是找伴一起參加"
    )
    let placeTileView = TileView(
        title: "聚會地點",
        placeholder: "碰面的方式，或者地址"
    )
    let descriptionTileView = TileView(
        title: "聚會描述",
        placeholder: "描述你想要聚會的原因，讓大家更能夠了解這場聚會的目的"
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
    }
    
    fileprivate func setup() {
        meetTimeTileView.delegate = self
        [
            imageHeaderView, titleTileView, placeTileView, meetTimeTileView, descriptionTileView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    fileprivate func style() {
        setupNavigationButtons()
        view.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        stackView.backgroundColor = .clear
    }
    
    fileprivate func layout() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.leftAnchor,
                          bottom: view.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 8, paddingLeft: 8, paddingRight: 8)
        
        scrollView.addSubview(stackView)
        stackView.fillSuperView()
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        imageHeaderView.setHeight(104)
    }
    
    // MARK: - Helpers
    
    func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Icons_24px_Back02")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.right")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleUpload)
        )
    }
    
    func checkIfMeetCanArranged() {
        guard let selectedImage = selectedImage,
              let chosenDate = chosenDate,
              let meetTitleText = meetTitleText, !meetTitleText.isEmpty,
              let meetPlaceText = meetPlaceText, !meetPlaceText.isEmpty,
              let meetDescription = meetDescription, !meetDescription.isEmpty
        else {
            print("DEBUG: upload\(selectedImage) \(chosenDate) \(meetTitleText) \(meetPlaceText) \(meetDescription)")
            print("DEBUG: Something is nil")
            return
        }
        print("DEBUG: upload\(selectedImage) \(chosenDate) \(meetTitleText) \(meetPlaceText) \(meetDescription)")
    }
    
    // MARK: - Action
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleUpload() {
        checkIfMeetCanArranged()
    }
    
}

extension ArrangeMeetController: MeetTimeTileViewDelegate {
    func didChooseDate(_ selector: MeetTimeTileView, date: Date) {
        self.chosenDate = date
    }
}

class ImageHeaderView: UIView {
    
    lazy var picView: PicView = {
        let view = PicView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picView)
        picView.centerX(inView: self)
        picView.centerY(inView: self)
        picView.setDimensions(height: 104, width: 104)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class PicView: UIView {
    
    lazy var placedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(placedImageView)
        placedImageView.fillSuperView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
