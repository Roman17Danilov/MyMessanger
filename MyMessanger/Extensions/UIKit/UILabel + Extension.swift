//
//  UILabel + Extension.swift
//  MyMessanger
//
//  Created by Roman on 20.02.2026.
//

import UIKit

extension UILabel {
    
    convenience init(text: String, font: UIFont? = .avenir20()) {
        self.init()
        
        self.text = text
        self.font = font
    }
}

