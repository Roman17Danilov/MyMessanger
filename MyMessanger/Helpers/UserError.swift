//
//  UserError.swift
//  MyMessanger
//
//  Created by Roman on 22.02.2026.
//

import Foundation

enum UserError {
    case notFilled, photoNotExist
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Fill all fields", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Photo not found", comment: "")
        }
    }
}
