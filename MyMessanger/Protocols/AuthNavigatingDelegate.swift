//
//  AuthNavigatingDelegate.swift
//  MyMessanger
//
//  Created by Roman on 21.02.2026.
//

import Foundation

protocol AuthNavigatingDelegate: AnyObject {
    func toLoginVC()
    func toSignUpVC()
}
