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
    let textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    
    var value: Float = 0

    // MARK: - View
    private let filterTool: FilterToolItem
    private let cancelButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    private lazy var sliderView = HorizontalSliderView(
        frame: CGRect(
            x: 30,
            y: frame.height / 2 - 50,
            width: frame.width - 60,
            height: 70
        )
    )

    // MARK: - Initializer
    init(frame: CGRect, filterTool: FilterToolItem, value: Float = 1.0) {
        self.filterTool = filterTool
        
        super.init(frame: frame)
        
        setupCancelButton()
        setupDoneButton()
        setupTitleLabel()
        setupSliderView(value: value)
        
        backgroundColor = .white
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonY = frame.height - cancelButton.frame.height - windowSafeAreaInsets.bottom
        
        cancelButton.frame.origin = CGPoint(x: 0, y: buttonY)
        cancelButton.frame = CGRect(
            x: 0,
            y: frame.height - buttonHeight,
            width: frame.width / 2,
            height: buttonHeight
        )
        
        doneButton.frame.origin = CGPoint(
            x: frame.width / 2,
            y: buttonY
        )
        doneButton.frame = CGRect(
            x: frame.width / 2,
            y: frame.height - buttonHeight,
            width: frame.width / 2,
            height: buttonHeight
        )
    }

    // MARK: - Helper
    func setPosition(offScreen isOffScreen: Bool) {
        if isOffScreen {
            frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y + 44)
            alpha = 0
        } else {
            frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y - 44)
            alpha = 1
        }
    }
    
    // MARK: - Action
    @objc private func cancelButtonTapped() {
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
        titleLabel.center = CGPoint(x: xPosition, y: frame.height/2 - 60)
        delegate?.filterControlView(self,
                                    didChangeValue: sender.value,
                                    filterTool: filterTool)
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
    }
    
    private func setupDoneButton() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.tintColor = .clear
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        doneButton.setTitleColor(textColor, for: .normal)
        doneButton.setTitle("Done", for: .normal)
        addSubview(doneButton)
        
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.textColor = textColor
    }
    
    private func setupSliderView(value: Float) {
        sliderView.slider.addTarget(self,
                                    action: #selector(sliderValueChanged(_:)),
                                    for: .valueChanged)
        sliderView.slider.value = value
        sliderView.valueRange = filterTool.slider
        addSubview(sliderView)
    }
    
}
