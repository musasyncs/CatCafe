//
//  ArrangeMeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit
import Firebase

class ArrangeMeetController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            imageHeaderView.picView.placedImageView.image = selectedImage
        }
    }
    private var chosenDate: Date?
    private var meetTitleText: String? {
        titleTileView.textField.text
    }
    private var selectedCafe: Cafe? {
        didSet {
            placeTileView.textField.text = selectedCafe?.title
        }
    }
    private var meetDescription: String? {
        descriptionTileView.textField.text
    }
    
    var keyboardIsPresent = false
    
    // MARK: - View
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let imageHeaderView = ImageHeaderView()
    private let titleTileView = TileView(
        title: "聚會主題",
        placeholder: "開啟你想討論的話題，或是找伴一起參加"
    )
    private let placeTileView = TileView(
        title: "聚會地點",
        placeholder: "選擇咖啡廳"
    )
    private let meetTimeTileView = MeetTimeTileView()
    private let descriptionTileView = TileView(
        title: "聚會描述",
        placeholder: "描述你想要聚會的原因，讓大家更能夠了解這場聚會的目的"
    )
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationButtons()
        setupScrollView()
        setupStackView()
        setupChildViews()
        setupDismissKeyboardWhenTapped()
    }
    
    private func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .ccGrey
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.asset(.Icons_24px_Back02)?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: SFSymbols.arrow_right?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleUpload)
        )
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.leftAnchor,
                          bottom: view.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 8, paddingLeft: 8, paddingBottom: 16, paddingRight: 8)
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        stackView.backgroundColor = .clear
        scrollView.addSubview(stackView)
        stackView.centerX(inView: scrollView)
        stackView.fillSuperView()
    }
    
    private func setupChildViews() {
        stackView.addArrangedSubview(imageHeaderView)
        stackView.addArrangedSubview(titleTileView)
        stackView.addArrangedSubview(placeTileView)
        stackView.addArrangedSubview(meetTimeTileView)
        stackView.addArrangedSubview(descriptionTileView)
        
        imageHeaderView.setHeight(104)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSelectCafePage))
        placeTileView.textField.addGestureRecognizer(tap)
        placeTileView.textField.isUserInteractionEnabled = true
        
        meetTimeTileView.delegate = self
        
        descriptionTileView.textField.tag = 2
        descriptionTileView.delegate = self
    }
    
    private func setupDismissKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
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
            AlertHelper.showMessage(title: "Validate Failed", message: "欄位不可留白", buttonTitle: "OK", over: self)
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        MeetService.uploadMeet(
            title: meetTitleText,
            caption: meetDescription,
            meetImage: selectedImage,
            cafeId: selectedCafe.id,
            cafeName: selectedCafe.title,
            meetDate: chosenDate
        ) { [weak self] error in
            guard let self = self else { return }
        
            if error != nil {
                self.showFailure(text: "Failed to upload meet")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: CCConstant.NotificationName.updateMeetFeed, object: nil)
            })
            
        }
        
    }
    
    @objc func showSelectCafePage() {
        let controller = SelectCafeController()
        controller.delegate = self
        let navController = makeNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
    
    @objc func dismissKeyboard() {
        titleTileView.textField.resignFirstResponder()
    }
}

// MARK: - SelectCafeControllerDelegate, MeetTimeTileViewDelegate
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

// MARK: - TileViewDelegate
extension ArrangeMeetController: TileViewDelegate {
    
    func scrollToOriginalPlace() {
        scrollView.contentOffset.y = 0
    }
    
    func tileView(_ tileView: TileView, wantsToScrollToTextField textField: UITextField) {
        if tileView.textField.tag == 2 {
            scrollView.contentOffset.y = (tileView.frame.minY) + CGFloat(-250)
        }
    }

}
