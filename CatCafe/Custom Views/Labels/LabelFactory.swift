//
//  LabelFactory.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/20.
//

import UIKit

func makeLabel(withTitle title: String, font: UIFont, textColor: UIColor) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = title
    label.font = font
    label.textAlignment = .left
    label.textColor = textColor
    label.backgroundColor = .clear
    label.numberOfLines = 0
    label.adjustsFontSizeToFitWidth = true
    return label
}
