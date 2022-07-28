//
//  FilterControlView.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/25.
//

import UIKit

protocol FilterControlViewDelegate: AnyObject {
    func filterControlViewDidPressCancel()
    func filterControlViewDidPressDone()
    func filterControlView(_ controlView: FilterControlView, didChangeValue value: Float, filterTool: FilterToolItem)
}

class FilterControlView: UIView {

    weak var delegate: FilterControlViewDelegate?
    let buttonHeight: CGFloat = 52
    let textColor = UIColor.ccGrey
    
    var value: Float = 0

    // MARK: - View
    private let filterTool: FilterToolItem
    private let cancelButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private lazy var sliderView = HorizontalSliderView()

    // MARK: - Init
    init(frame: CGRect, filterTool: FilterToolItem, value: Float = 1.0) {
        self.filterTool = filterTool
        super.init(frame: frame)
        
        backgroundColor = .white
        isUserInteractionEnabled = true
        setupCancelButton()
        setupDoneButton()
        setupTitleLabel()
        setupSliderView(value: value)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    // MARK: - Public
    func setPosition(offScreen isOffScreen: Bool) {
        if isOffScreen {
            frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y + 22)
            alpha = 0
        } else {
            frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y - 22)
            alpha = 1
        }
    }
    
    // MARK: - Action
    @objc private func cancelButtonTapped() {
        self.titleLabel.removeFromSuperview()
        delegate?.filterControlViewDidPressCancel()
    }
    
    @objc private func doneButtonTapped() {
        delegate?.filterControlViewDidPressDone()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        titleLabel.text = "\(Int(sender.value * 100))"
        
        let trackRect = sender.trackRect(forBounds: sender.bounds)
        let thumbRect = sender.thumbRect(forBounds: sender.bounds,
                                         trackRect: trackRect,
                                         value: sender.value)
        let xPosition = thumbRect.origin.x + sender.frame.origin.x + 44
        titleLabel.center = CGPoint(x: xPosition, y: frame.height / 2 - 40)
        
        delegate?.filterControlView(self, didChangeValue: sender.value, filterTool: filterTool)
    }
    
}

extension FilterControlView {
    
    private func setupCancelButton() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.tintColor = .clear
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(textColor, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        addSubview(cancelButton)
        cancelButton.anchor(left: leftAnchor,
                            bottom: safeAreaLayoutGuide.bottomAnchor,
                            paddingBottom: 24)
        cancelButton.setDimensions(height: buttonHeight, width: ScreenSize.width / 2)
    }
    
    private func setupDoneButton() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.tintColor = .clear
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        doneButton.setTitleColor(textColor, for: .normal)
        doneButton.setTitle("Done", for: .normal)
        addSubview(doneButton)
        doneButton.anchor(bottom: safeAreaLayoutGuide.bottomAnchor,
                          right: rightAnchor,
                          paddingBottom: 24)
        doneButton.setDimensions(height: buttonHeight, width: ScreenSize.width / 2)
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.setDimensions(height: 44, width: 44)
    }
    
    private func setupSliderView(value: Float) {
        sliderView.slider.addTarget(self,
                                    action: #selector(sliderValueChanged(_:)),
                                    for: .valueChanged)
        sliderView.slider.value = value
        sliderView.valueRange = filterTool.slider
        addSubview(sliderView)
        sliderView.centerY(inView: self)
        sliderView.setDimensions(height: 70, width: ScreenSize.width - 60)
        sliderView.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 30, paddingRight: 30)
    }
    
}
