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
    var selectedCafe: Cafe? {
        didSet {
            placeTileView.textField.text = selectedCafe?.title
        }
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
        placeholder: "選擇咖啡廳"
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
            imageHeaderView,
            titleTileView,
            placeTileView,
            meetTimeTileView,
            descriptionTileView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        placeTileView.textField.inputView = UIView()
        placeTileView.textField.tintColor = .white
        placeTileView.textField.addTarget(self, action: #selector(showSelectCafePage), for: .editingDidBegin)
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
                          paddingTop: 8, paddingLeft: 8, paddingBottom: 16, paddingRight: 8)
        
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
    
    // MARK: - Action
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleUpload() {
        guard let selectedImage = selectedImage,
              let chosenDate = chosenDate,
              let selectedCafe = selectedCafe,
              let meetTitleText = meetTitleText, !meetTitleText.isEmpty,
              let meetDescription = meetDescription, !meetDescription.isEmpty
        else {
            showMessage(withTitle: "Validate Failed", message: "欄位不可留白")
            return
        }
        
        // Uploading...
        navigationItem.rightBarButtonItem?.isEnabled = false
        showLoader(true)
        
        MeetService.uploadMeet(title: meetTitleText,
                               caption: meetDescription,
                               meetImage: selectedImage,
                               cafeId: selectedCafe.id,
                               cafeName: selectedCafe.title) { error in
            self.showLoader(false)
            
            if let error = error {
                print("DEBUG: Failed to upload meet with error \(error.localizedDescription)")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: CCConstant.NotificationName.updateMeetFeed, object: nil)
            })

        }
        
        print("DEBUG: upload\(selectedImage) \(chosenDate) \(meetTitleText) \(selectedCafe.title) \(meetDescription)")
    }
    
    @objc func showSelectCafePage() {
        let controller = SelectCafeController()
        controller.delegate = self
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
}

extension ArrangeMeetController: SelectCafeControllerDelegate {
    func didSelectCafe(_ cafe: Cafe) {
        self.selectedCafe = cafe
    }
}

extension ArrangeMeetController: MeetTimeTileViewDelegate {
    func didChooseDate(_ selector: MeetTimeTileView, date: Date) {
        self.chosenDate = date
    }
}
