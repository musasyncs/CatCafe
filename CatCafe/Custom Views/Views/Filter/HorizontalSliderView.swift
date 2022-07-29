//
//  HorizontalSliderView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/19.
//

import UIKit

class HorizontalSliderView: UIView {
    
    var valueRange: SliderValueRange = .zeroToHundred
    
    // MARK: - View
    private var trackView = UIView()
    private let minTrack = UIView()
    let slider = UISlider()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackView.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        addSubview(trackView)
        
        minTrack.backgroundColor = UIColor(red: 0.21, green: 0.21, blue: 0.21, alpha: 1)
        addSubview(minTrack)
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        addSubview(slider)
        slider.fillSuperView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let trackRect = self.slider.convert(self.slider.trackRect(forBounds: self.slider.bounds), to: self)
        self.trackView.frame = CGRect(x: trackRect.origin.x,
                                      y: trackRect.midY,
                                      width: trackRect.width,
                                      height: 1)
        
        let thumbRect = self.slider.convert(
            self.slider.thumbRect(
                forBounds: self.slider.bounds,
                trackRect: self.slider.trackRect(forBounds: self.slider.bounds),
                value: self.slider.value
            ), to: self
        )
        
        switch valueRange {
        case .zeroToHundred:
            self.minTrack.frame = CGRect(
                x: trackRect.origin.x,
                y: trackRect.midY,
                width: thumbRect.midX,
                height: 1)
        }
        
    }

    // MARK: - Action
    @objc private func sliderValueChanged(_ sender: UISlider) {
        self.setNeedsLayout()
    }

}
