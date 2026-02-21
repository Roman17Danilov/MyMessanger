//
//  SelfConfiguringCell.swift
//  MyMessanger
//
//  Created by Roman on 20.02.2026.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}

