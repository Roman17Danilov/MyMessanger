//
//  AuthError.swift
//  MyMessanger
//
//  Created by Roman on 21.02.2026.
//

import Foundation

enum AuthError {
    case notFilled, invalidEmail, passwordNotMatched, unknownError, serverError, googleAuthFailed
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Fill all fields", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Wrong email format", comment: "")
        case .passwordNotMatched:
            return NSLocalizedString("Passwords does not match", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown error", comment: "")
        case .serverError:
            return NSLocalizedString("Server error", comment: "")
        case .googleAuthFailed:
            return NSLocalizedString("Problems with google account", comment: "")
        }
    }
}
