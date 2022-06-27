//
//  String+Extension.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import Foundation

extension String {
        
    static let empty = ""
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
}
