//
//  UserError.swift
//  MyMessanger
//
//  Created by Roman on 22.02.2026.
//

import Foundation

enum UserError {
    case notFilled, photoNotExist, cannotGetUserInfo, cannotUnwrapToUser
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Fill all fields", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Photo not found", comment: "")
        case .cannotGetUserInfo:
            return NSLocalizedString("Can not get user info", comment: "")
        case .cannotUnwrapToUser:
            return NSLocalizedString("Can not conver MUser to User from firebase", comment: "")
        }
    }
}
