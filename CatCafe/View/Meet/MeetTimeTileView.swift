//
//  MeetTimeTileView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

protocol MeetTimeTileViewDelegate: AnyObject {
    func didChooseDate(_ selector: MeetTimeTileView, date: Date)
}

class MeetTimeTileView: UIView {
    
    weak var delegate: MeetTimeTileViewDelegate?
    
    let titleLabel = UILabel()
    var openButton = UIButton()
    let noticeLabel = UILabel()
    
    let timeSelectorView = TimeSelectorView()
    lazy var textField = CustomTextField(placeholder: "聚會會維持公開直到聚會時間，如果要提早關閉，可以使用刪除功能",
                                         textColor: .black,
                                         fgColor: .systemBrown,
                                         font: .notoRegular(size: 11))
    
    var heightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        titleLabel.text = "聚會時間"
        titleLabel.font = .notoMedium(size: 15)
        titleLabel.textColor = .black
        
        makeOpenButton()
        
        noticeLabel.text = "請選擇聚會時間"
        noticeLabel.font = .notoRegular(size: 11)
        noticeLabel.textColor = .systemRed
        
        timeSelectorView.delegate = self
        timeSelectorView.isHidden = true
        textField.isEnabled = false
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layout() {
        // For animation
        
        // layout
        addSubview(titleLabel)
        addSubview(openButton)
        addSubview(noticeLabel)
        addSubview(timeSelectorView)
        addSubview(textField)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingLeft: 8, height: 36)
        openButton.centerY(inView: titleLabel,
                           leftAnchor: titleLabel.rightAnchor,
                           paddingLeft: 4)
        noticeLabel.centerY(inView: openButton,
                            leftAnchor: openButton.rightAnchor,
                            paddingLeft: 4)
        
        heightConstraint = timeSelectorView.heightAnchor.constraint(equalToConstant: 0)  // For animation
        heightConstraint!.isActive = true
        timeSelectorView.anchor(top: titleLabel.bottomAnchor,
                                left: leftAnchor,
                                right: rightAnchor,
                                paddingTop: 8, paddingLeft: 8, paddingRight: 8)
        
        textField.anchor(top: timeSelectorView.bottomAnchor,
                         left: leftAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         paddingTop: 8,
                         height: 36)
    }
    
    // MARK: - Helpers
    
    func makeOpenButton() {
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .primaryActionTriggered)
        
        let configuration = UIImage.SymbolConfiguration(scale: .small)
        let image = UIImage(systemName: "chevron.down", withConfiguration: configuration)
        openButton.setImage(image, for: .normal)
        
        openButton.imageView?.tintColor = .label
        openButton.imageView?.contentMode = .scaleAspectFit
    }
    
    private func setChevronUp() {
        let configuration = UIImage.SymbolConfiguration(scale: .small)
        let image = UIImage(systemName: "chevron.up", withConfiguration: configuration)
        openButton.setImage(image, for: .normal)
    }
    
    private func setChevronDown() {
        let configuration = UIImage.SymbolConfiguration(scale: .small)
        let image = UIImage(systemName: "chevron.down", withConfiguration: configuration)
        openButton.setImage(image, for: .normal)
    }

    // MARK: - Actions
    
    @objc func openButtonTapped() {
        if heightConstraint?.constant == 0 {
            self.setChevronUp()
            
            let heightAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                self.heightConstraint?.constant = 96
                self.layoutIfNeeded()
            }
            heightAnimator.startAnimation()
            
            let alphaAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                self.timeSelectorView.isHidden = false
                self.timeSelectorView.alpha = 1
                self.noticeLabel.isHidden = true
            }
            alphaAnimator.startAnimation(afterDelay: 0.5)
            
        } else {
            self.setChevronDown()
            
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                self.heightConstraint?.constant = 0
                self.timeSelectorView.isHidden = true
                self.timeSelectorView.alpha = 0
                self.noticeLabel.isHidden = false
                self.layoutIfNeeded()
            }
            animator.startAnimation()
        }
    }
    
}

extension MeetTimeTileView: TimeSelectorViewDelegate {
    func didChooseDate(_ selector: TimeSelectorView, date: Date) {
        delegate?.didChooseDate(self, date: date)
    }
    
}

protocol TimeSelectorViewDelegate: AnyObject {
    func didChooseDate(_ selector: TimeSelectorView, date: Date)
}

final class TimeSelectorView: UIView {
    
    weak var delegate: TimeSelectorViewDelegate?
    
    var datePicker: UIDatePicker!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 96, height: 24))
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        datePicker.minimumDate = Date().addingTimeInterval(60 * 60 * 5)
        datePicker.maximumDate = Date().addingTimeInterval(60 * 60 * 24 * 90)
        datePicker.locale = Locale(identifier: "zh_TW")
        datePicker.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 15
        
        datePicker.tintColor = .systemBrown
        
        addSubview(datePicker)
        datePicker.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func datePickerChanged(datePicker: UIDatePicker) {
        delegate?.didChooseDate(self, date: datePicker.date)
    }
}
