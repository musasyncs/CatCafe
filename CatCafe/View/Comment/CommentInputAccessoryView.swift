//
//  CommentInputAccessoryView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/18.
//

import UIKit

protocol CommentInputAccessoryViewDelegate: AnyObject {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String)
}

class CommentInputAccessoryView: UIView {
    
    weak var delegate: CommentInputAccessoryViewDelegate?
    
    lazy var commentTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderText = "新增留言..."
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.backgroundColor = .white
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.placeholderShouldCenter = true
        return textView
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("發佈", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(handlePostTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        addSubview(postButton)
        addSubview(commentTextView)
        postButton.anchor(top: topAnchor, right: rightAnchor, paddingRight: 8)
        postButton.setDimensions(height: 50, width: 50)
        commentTextView.anchor(top: topAnchor,
                               left: leftAnchor,
                               bottom: safeAreaLayoutGuide.bottomAnchor,
                               right: postButton.leftAnchor,
                               paddingTop: 8, paddingLeft: 8,
                               paddingBottom: 8, paddingRight: 8)
        
        let divider = UIView()
        divider.backgroundColor = .systemGray3
        addSubview(divider)
        divider.anchor(top: topAnchor,
                       left: leftAnchor,
                       right: rightAnchor,
                       height: 0.5
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // MARK: - Helpers
    
    func clearCommentTextView() {
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
    }
    
    // MARK: - Actions
    
    @objc func handlePostTapped() {
        delegate?.inputView(self, wantsToUploadComment: commentTextView.text)
    }
    
}

extension CommentInputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            self.postButton.setTitleColor(UIColor.black, for: .normal)
            self.postButton.isEnabled = true
        } else {
            self.postButton.setTitleColor(UIColor.lightGray, for: .normal)
            self.postButton.isEnabled = false
        }
    }
}
