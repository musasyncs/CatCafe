//
//  PostEditController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit
import Firebase
import Photos

class PostEditController: UIViewController {
    
    var image: UIImage? {
        didSet {
            self.postImageView.image = image
        }
    }
    
    private var selectedCafe: Cafe? {
        didSet {
            guard let selectedCafe = selectedCafe else { return }
            
            let titleAttrText = NSAttributedString(
                string: selectedCafe.title,
                attributes: [
                    .foregroundColor: UIColor.ccPrimary,
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium) as Any
                ])
            titleLabel.attributedText = titleAttrText
            
            let subtitleAttrText = NSAttributedString(
                string: selectedCafe.address,
                attributes: [
                    .foregroundColor: UIColor.gray3,
                    .font: UIFont.systemFont(ofSize: 11, weight: .medium) as Any
                ])
            subtitleLabel.attributedText = subtitleAttrText
            
            cafeHoriStack.isHidden = false
        }
    }
    
    // MARK: - View
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 36 / 2
        imageView.backgroundColor = .gray6
        return imageView
    }()
    
    private lazy var captionTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderText = "請輸入文字"
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.placeholderShouldCenter = false
        return textView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.text = "0/1000"
        label.textAlignment = .center
        return label
    }()
    
    private let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        return view
    }()
    
    private let tableView = UITableView()
    
    private let addPlaceButton = makeTitleButton(
        withText: "選擇咖啡廳",
        font: .systemFont(ofSize: 13, weight: .regular)
    )
    
    private let iconButton = makeIconButton(
        imagename: "location",
        imageColor: .ccPrimary,
        imageWidth: 18,
        imageHeight: 18
    )
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private lazy var cafeVerticalStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    private lazy var cafeHoriStack = UIStackView(arrangedSubviews: [iconButton, cafeVerticalStack])
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBarButtonItem()
        setupContainerView()
        setupAddPlaceButton()
        setupStackView()
        
        fetchProfilePic()
    }
    
    // MARK: - API
    private func fetchProfilePic() {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        UserService.shared.fetchUserBy(uid: currentUid, completion: { [weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.profileImageView.loadImage(user.profileImageUrlString)
            }
        })
    }
    
    // MARK: - Action
    @objc func handleCancel() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc func showSelectCafePage() {
        let controller = SelectCafeController()
        controller.delegate = self
        let navController = makeNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
    
    @objc private func handleImagePost() {
        guard let postImage = image else { return }
        guard let caption = captionTextView.text, !caption.isEmpty else {
            AlertHelper.showMessage(title: "Validate Failed", message: "請撰寫貼文", buttonTitle: "OK", over: self)
            return
        }
        guard let selectedCafe = selectedCafe else {
            AlertHelper.showMessage(title: "Validate Failed", message: "請選擇咖啡廳", buttonTitle: "OK", over: self)
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        PostService.shared.uploadImagePost(caption: caption,
                                           postImage: postImage,
                                           cafeId: selectedCafe.id,
                                           cafeName: selectedCafe.title) { [weak self] error in
            guard let self = self else { return }
            
            if error != nil {
                self.showFailure(text: "Failed to upload post")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            self.dismiss(animated: true) {
                // save photo
                PHPhotoLibrary.shared().performChanges {
                    PHAssetCreationRequest.creationRequestForAsset(from: postImage)
                }
                // notify feed update
                NotificationCenter.default.post(name: CCConstant.NotificationName.updateFeed, object: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension PostEditController {
    
    func setupBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: SFSymbols.arrow_left?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.asset(.check)?
                .resize(to: .init(width: 24, height: 24))?
                .withTintColor(.ccPrimary)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleImagePost)
        )
    }
    
    func setupContainerView() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        view.addSubview(seperatorLine)
        containerView.addSubviews(profileImageView, captionTextView, postImageView, characterCountLabel)
        
        containerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor
        )
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
        
        profileImageView.centerY(
            inView: containerView,
            leftAnchor: containerView.leftAnchor,
            paddingLeft: 8, constant: 0
        )
        profileImageView.setDimensions(height: 36, width: 36)
        
        captionTextView.anchor(
            top: containerView.topAnchor,
            left: profileImageView.rightAnchor,
            bottom: containerView.bottomAnchor,
            right: postImageView.leftAnchor,
            paddingLeft: 8, paddingRight: 32
        )
        
        postImageView.anchor(right: containerView.rightAnchor, paddingRight: 16)
        postImageView.centerY(inView: containerView)
        postImageView.setDimensions(height: 56, width: 56)
        
        characterCountLabel.anchor(left: postImageView.leftAnchor, bottom: captionTextView.bottomAnchor)
        
        seperatorLine.anchor(
            top: containerView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 8,
            height: 0.5
        )
    }
    
    func setupAddPlaceButton() {
        addPlaceButton.addTarget(self, action: #selector(showSelectCafePage), for: .touchUpInside)
        view.addSubview(addPlaceButton)
        addPlaceButton.anchor(top: seperatorLine.bottomAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8)
    }
    
    func setupStackView() {
        cafeVerticalStack.axis = .vertical
        cafeVerticalStack.alignment = .leading
        cafeVerticalStack.distribution = .equalSpacing
        cafeVerticalStack.spacing = 4
        
        cafeHoriStack.axis = .horizontal
        cafeHoriStack.alignment = .center
        cafeHoriStack.distribution = .equalSpacing
        cafeHoriStack.spacing = 8
        
        view.addSubview(cafeHoriStack)
        cafeHoriStack.anchor(top: addPlaceButton.bottomAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        cafeHoriStack.isHidden = true
    }
}

// MARK: - UITextViewDelegate
extension PostEditController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxlength(textView)
        let count = textView.text.count
        characterCountLabel.text  = "\(count)/1000"
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    private func checkMaxlength(_ textView: UITextView) {
        if textView.text.count > 1000 {
            textView.deleteBackward()
        }
    }
}

// MARK: - SelectCafeControllerDelegate
extension PostEditController: SelectCafeControllerDelegate {
    
    func didSelectCafe(_ cafe: Cafe) {
        self.selectedCafe = cafe
    }
    
}
