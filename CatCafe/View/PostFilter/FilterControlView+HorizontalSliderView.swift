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
    
    var value: Float = 0
    
    private let cancelButton: UIButton
    private let doneButton: UIButton
    private let titleLabel: UILabel
    private let sliderView: HorizontalSliderView
    
    private let filterTool: FilterToolItem
    
    init(frame: CGRect, filterTool: FilterToolItem, value: Float = 1.0) {
        self.filterTool = filterTool
        
        let textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        
        cancelButton = UIButton(type: .system)
        cancelButton.tintColor = .clear
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(textColor, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        
        doneButton = UIButton(type: .system)
        doneButton.tintColor = .clear
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        doneButton.setTitleColor(textColor, for: .normal)
        doneButton.setTitle("Done", for: .normal)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        titleLabel.textAlignment = .center
        titleLabel.textColor = textColor
        
        sliderView = HorizontalSliderView(
            frame: CGRect(
                x: 30, y: frame.height/2 - 50,
                width: frame.width - 60,
                height: 70
            ))
        
        super.init(frame: frame)
        
        sliderView.valueRange = filterTool.slider
        sliderView.slider.value = value
        
        backgroundColor = .white
        isUserInteractionEnabled = true
        
        addSubview(titleLabel)
        addSubview(sliderView)
        addSubview(cancelButton)
        addSubview(doneButton)
        let buttonHeight: CGFloat = 52
        cancelButton.frame = CGRect(x: 0, y: frame.height - buttonHeight, width: frame.width/2, height: buttonHeight)
        doneButton.frame = CGRect(x: frame.width/2,
                                  y: frame.height - buttonHeight,
                                  width: frame.width/2,
                                  height: buttonHeight)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        sliderView.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonY = frame.height - cancelButton.frame.height - keyWindowSafeAreaInsets.bottom
        cancelButton.frame.origin = CGPoint(x: 0, y: buttonY)
        doneButton.frame.origin = CGPoint(x: frame.width/2, y: buttonY)
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
        let thumbRect = sender.thumbRect(forBounds: sender.bounds, trackRect: trackRect, value: sender.value)
        let xPosition = thumbRect.origin.x + sender.frame.origin.x + 44
        titleLabel.center = CGPoint(x: xPosition, y: frame.height/2 - 60)
        delegate?.filterControlView(self, didChangeValue: sender.value, filterTool: filterTool)
    }
    
}

/// Slider Value Range
///
/// - zeroToHundred: value in [0, 100]
/// - negHundredToHundred: value in [-100, 100], defaluts to 0
/// - tiltShift: tiltShift
/// - adjustStraighten: adjustStraighten, specially handled
///

enum SliderValueRange {
    case zeroToHundred
    case negHundredToHundred
    case tiltShift
    case adjustStraighten
}

class HorizontalSliderView: UIView {

    var valueRange: SliderValueRange = .zeroToHundred {
        didSet {
            switch valueRange {
            case .adjustStraighten, .tiltShift:
                break
            case .negHundredToHundred:
                slider.maximumValue = 1
                slider.minimumValue = -1
            case .zeroToHundred:
                slider.maximumValue = 1
                slider.minimumValue = 0
            }
        }
    }
    
    weak var slider: UISlider!
    weak var trackAdjustmentIndicator: UIView!
    
    var value: Float = 0 {
        didSet {
            originValue = value
        }
    }
    
    private weak var trackView: UIView!
    private var feedbackGenerator: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    private var originValue: Float = 0
    private var isSliding: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        let trackView = UIView(frame: .zero)
        trackView.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        self.addSubview(trackView)
        self.trackView = trackView
        
        let trackAdjustmentIndicator = UIView(frame: .zero)
        trackAdjustmentIndicator.backgroundColor = UIColor(red: 0.21, green: 0.21, blue: 0.21, alpha: 1)
        self.addSubview(trackAdjustmentIndicator)
        self.trackAdjustmentIndicator = trackAdjustmentIndicator
        
        let slider = UISlider(frame: self.bounds)
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        self.addSubview(slider)
        self.slider = slider
        
        self.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        self.setNeedsLayout()
        
        if sender.value == sender.minimumValue || sender.value == sender.maximumValue {
            if isSliding {
                feedbackGenerator.selectionChanged()
            }
        }
    }
    
    @objc private func tap(_ gesture: UITapGestureRecognizer) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSliding = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        isSliding = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.slider.frame.size = CGSize(width: self.bounds.width, height: self.bounds.height)
        self.slider.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let thumbRect = self.slider.convert(self.slider.thumbRect(forBounds: self.slider.bounds, trackRect: self.slider.trackRect(forBounds: self.slider.bounds), value: self.slider.value), to: self)
        let trackRect = self.slider.convert(self.slider.trackRect(forBounds: self.slider.bounds), to: self)
        self.trackView.frame = CGRect(x: trackRect.origin.x, y: trackRect.midY, width: trackRect.width, height: 1)
        
        
        switch valueRange {
        case .zeroToHundred:
            self.trackAdjustmentIndicator.frame = CGRect(x: trackRect.origin.x,
                                                         y: trackRect.midY,
                                                         width: thumbRect.midX,
                                                         height: 1)
        case .negHundredToHundred:
            self.trackAdjustmentIndicator.frame = CGRect(x: trackRect.midX,
                                                         y: trackRect.midY,
                                                         width: thumbRect.midX - trackRect.midX,
                                                         height: 1)
        default:
            break
        }
        
    }

}

