//
//  FilterToolItem.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/25.
//

import Foundation

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

struct FilterToolItem {
    
    enum FilterToolType {
        case adjustStrength
    }
    
    let type: FilterToolType
    let slider: SliderValueRange
    
    var title: String {
        switch type {
        case .adjustStrength:
            return "Strength"
        }
    }

}
