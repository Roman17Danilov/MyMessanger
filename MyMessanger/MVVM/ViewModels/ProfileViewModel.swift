//
//  ProfileViewModel.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol ProfileViewModelDelegate: AnyObject {
    func profileDidUpdate()
    func errorDidOccur(error: String)
    func sendMessageDidSucceed(message: String, receiver: MUser)
}

class ProfileViewModel {
    weak var delegate: ProfileViewModelDelegate?

    private let user: MUser

    init(user: MUser) {
        self.user = user
    }

    // MARK: - Public getters
    var username: String {
        user.username
    }

    var description: String {
        user.description
    }

    var avatarStringURL: String {
        user.avatarStringURL
    }

    // MARK: - Actions
    func sendMessage(message: String) {
        FirestoreService.shared.createWaitingChat(message: message, receiver: user) { result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.delegate?.sendMessageDidSucceed(message: message, receiver: self.user)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }
}

