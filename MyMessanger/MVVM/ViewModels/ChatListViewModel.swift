//
//  ChatListViewModel.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

import Foundation
import FirebaseFirestore

protocol ChatListViewModelDelegate: AnyObject {
    func chatsDidUpdate()
    func errorDidOccur(error: String)
}

class ChatListViewModel {
    weak var delegate: ChatListViewModelDelegate?

    private var waitingChats: [MChat] = []
    private var activeChats: [MChat] = []

    private let currentUser: MUser

    private var waitingChatsListener: ListenerRegistration?
    private var activeChatsListener: ListenerRegistration?

    init(currentUser: MUser) {
        self.currentUser = currentUser
        observeWaitingChats()
        observeActiveChats()
    }

    deinit {
        waitingChatsListener?.remove()
        activeChatsListener?.remove()
    }

    // MARK: - Public getters
    var allWaitingChats: [MChat] { waitingChats }
    var allActiveChats: [MChat] { activeChats }
    
    var waitingChatsCount: Int {
        waitingChats.count
    }

    var activeChatsCount: Int {
        activeChats.count
    }

    func waitingChat(at index: Int) -> MChat? {
        guard index >= 0, index < waitingChats.count else { return nil }
        return waitingChats[index]
    }

    func activeChat(at index: Int) -> MChat? {
        guard index >= 0, index < activeChats.count else { return nil }
        return activeChats[index]
    }

    // MARK: - Firebase
    private func observeWaitingChats() {
        waitingChatsListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let chats):
                self.waitingChats = chats
                DispatchQueue.main.async {
                    self.delegate?.chatsDidUpdate()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }

    private func observeActiveChats() {
        activeChatsListener = ListenerService.shared.activeChatsObserve(chats: activeChats) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let chats):
                self.activeChats = chats
                DispatchQueue.main.async {
                    self.delegate?.chatsDidUpdate()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Actions
    func removeWaitingChat(chat: MChat) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }

    func changeToActive(chat: MChat) {
        FirestoreService.shared.changeToActive(chat: chat) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }

    func waitingChat(at indexPath: IndexPath) -> MChat? {
        guard indexPath.section == 0,
              indexPath.item >= 0,
              indexPath.item < waitingChats.count else { return nil }
        return waitingChats[indexPath.item]
    }

    func activeChat(at indexPath: IndexPath) -> MChat? {
        guard indexPath.section == 1,
              indexPath.item >= 0,
              indexPath.item < activeChats.count else { return nil }
        return activeChats[indexPath.item]
    }
}

