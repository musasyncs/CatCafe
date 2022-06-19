//
//  PostEditController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/16.
//

import UIKit
import Firebase

class PostEditController: UIViewController {
        
    var image: UIImage? {
        didSet {
            self.postImageView.image = image
        }
    }
    
    var selectedCafe: Cafe? {
        didSet {
            guard let selectedCafe = selectedCafe else { return }
            
            let titleAttrText = NSAttributedString(
                string: selectedCafe.title,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.notoMedium(size: 13) as Any
                ])
            titleLabel.attributedText = titleAttrText
            
            let subtitleAttrText = NSAttributedString(
                string: selectedCafe.title,
                attributes: [
                    .foregroundColor: UIColor.systemGray3,
                    .font: UIFont.notoMedium(size: 11) as Any
                ])
            subtitleLabel.attributedText = subtitleAttrText
            
            horiStack.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "check")?
                    .resize(to: .init(width: 24, height: 24))?
                    .withTintColor(.systemBlue)
                    .withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(handleImagePost)
            )
        }
    }

    // MARK: - UI
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemRed
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 36 / 2
        return imageView
    }()
    
    lazy var captionTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderText = "請輸入文字"
        textView.font = .systemFont(ofSize: 13, weight: .regular)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.placeholderShouldCenter = false
        return textView
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.text = "0/1000"
        label.textAlignment = .center
        return label
    }()
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let tableView = UITableView()
    
    let addPlaceButton = makeAttriTitleButton(
        text: "選擇咖啡廳",
        font: .systemFont(ofSize: 13, weight: .regular),
        fgColor: .black,
        kern: 1
    )
    
    let iconButton = makeIconButton(imagename: "location",
                                    imageColor: .systemBlue,
                                    imageWidth: 18,
                                    imageHeight: 18)
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    lazy var vertiStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    lazy var horiStack = UIStackView(arrangedSubviews: [iconButton, vertiStack])

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
    
    func fetchProfilePic() {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        
        UserService.fetchUserBy(uid: currentUid, completion: { user in
            self.profileImageView.sd_setImage(with: URL(string: user.profileImageUrlString))
        })
    }
    
    // MARK: - Helpers
    
    func setupBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "check")?
                .resize(to: .init(width: 24, height: 24))?
                .withTintColor(.gray)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: nil, action: nil
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func setupContainerView() {
        let containerView = UIView()
        containerView.backgroundColor = .white

        view.addSubview(containerView)
        view.addSubview(seperatorLine)
        containerView.addSubview(profileImageView)
        containerView.addSubview(captionTextView)
        containerView.addSubview(postImageView)
        containerView.addSubview(characterCountLabel)
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor)
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
        
        profileImageView.centerY(inView: containerView,
                                 leftAnchor: containerView.leftAnchor,
                                 paddingLeft: 8, constant: 0)
        profileImageView.setDimensions(height: 36, width: 36)
        
        captionTextView.anchor(top: containerView.topAnchor,
                               left: profileImageView.rightAnchor,
                               bottom: containerView.bottomAnchor,
                               right: postImageView.leftAnchor,
                               paddingLeft: 8, paddingRight: 32)
        
        postImageView.anchor(right: containerView.rightAnchor, paddingRight: 16)
        postImageView.centerY(inView: containerView)
        postImageView.setDimensions(height: 56, width: 56)
        
        characterCountLabel.anchor(left: postImageView.leftAnchor, bottom: captionTextView.bottomAnchor)
        
        seperatorLine.anchor(top: containerView.bottomAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 8,
                             height: 0.5)
    }
    
    func setupAddPlaceButton() {
        addPlaceButton.addTarget(self, action: #selector(showSelectCafePage), for: .touchUpInside)
        
        view.addSubview(addPlaceButton)
        addPlaceButton.anchor(top: seperatorLine.bottomAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8)
    }
    
    func setupStackView() {
        vertiStack.axis = .vertical
        vertiStack.alignment = .leading
        vertiStack.distribution = .equalSpacing
        vertiStack.spacing = 4
        
        horiStack.axis = .horizontal
        horiStack.alignment = .center
        horiStack.distribution = .equalSpacing
        horiStack.spacing = 8
        
        view.addSubview(horiStack)
        horiStack.anchor(top: addPlaceButton.bottomAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        horiStack.isHidden = true
    }
    
    func checkMaxlength(_ textView: UITextView) {
        if textView.text.count > 1000 {
            textView.deleteBackward()
        }
    }

    // MARK: - Actions
    
    @objc func handleCancel() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc func showSelectCafePage() {
        let controller = SelectCafeController()
        controller.delegate = self
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func handleImagePost() {
        guard let selectedImage = image else { return }
        guard let caption = captionTextView.text else { return }
        guard let selectedCafe = selectedCafe else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        showLoader(true)
        
        PostService.uploadImagePost(caption: caption,
                                    postImage: selectedImage,
                                    cafeId: selectedCafe.id,
                                    cafeName: selectedCafe.title) { error in
            self.showLoader(false)
            
            if let error = error {
                print("DEBUG: Failed to upload post with error \(error.localizedDescription)")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: CCConstant.NotificationName.updateFeed, object: nil)
            }
        }
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
}

// MARK: - SelectCafeControllerDelegate

extension PostEditController: SelectCafeControllerDelegate {
    
    func didSelectCafe(_ cafe: Cafe) {
        self.selectedCafe = cafe
    }
    
}
