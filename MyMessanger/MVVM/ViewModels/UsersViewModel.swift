//
//  UsersViewModel.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UsersListViewModelDelegate: AnyObject {
    func usersDidUpdate()
    func errorDidOccur(error: String)
    func logoutDidSucceed()
}

class UsersListViewModel {
    weak var delegate: UsersListViewModelDelegate?

    private var users: [MUser] = []
    private var searchText: String?

    private let currentUser: MUser

    private var usersListener: ListenerRegistration?

    init(currentUser: MUser) {
        self.currentUser = currentUser
        observeUsers()
    }

    deinit {
        usersListener?.remove()
    }

    // MARK: - Public getters
    var usersCount: Int {
        filteredUsers.count
    }

    func user(at index: Int) -> MUser? {
        guard index >= 0, index < filteredUsers.count else { return nil }
        return filteredUsers[index]
    }

    private var filteredUsers: [MUser] {
        if let text = searchText, !text.isEmpty {
            return users.filter { $0.contains(filter: text) }
        }
        return users
    }

    // MARK: - Firebase
    private func observeUsers() {
        usersListener = ListenerService.shared.usersObserve(users: users) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let users):
                self.users = users
                DispatchQueue.main.async {
                    self.delegate?.usersDidUpdate()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Actions
    func updateSearchText(_ text: String?) {
        self.searchText = text
        DispatchQueue.main.async {
            self.delegate?.usersDidUpdate()
        }
    }

    func signOut() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        do {
            try Auth.auth().signOut()
            window.rootViewController = UINavigationController(
                rootViewController: AppRouter.authScreen()
            )
            DispatchQueue.main.async {
                self.delegate?.logoutDidSucceed()
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.errorDidOccur(error: error.localizedDescription)
            }
        }
    }
}

