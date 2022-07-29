//
//  FilterToolItem.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/25.
//

enum SliderValueRange {
    case zeroToHundred
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
