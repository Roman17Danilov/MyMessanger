//
//  ChatViewModel.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//
import Foundation
import FirebaseFirestore

protocol ChatViewModelDelegate: AnyObject {
    func messagesDidUpdate()
    func errorDidOccur(error: String)
}

class ChatViewModel {
    weak var delegate: ChatViewModelDelegate?

    private var messages: [MMessage] = []
    private(set) var isLoading = false
    private var chat: MChat
    private var user: MUser
    private var messageListener: ListenerRegistration?

    init(chat: MChat, user: MUser, messageListener: ListenerRegistration? = nil) {
        self.chat = chat
        self.user = user
        self.messageListener = messageListener
        setupMessageListener()
    }

    deinit {
        messageListener?.remove()
    }

    // MARK: - Public getters
    var messageCount: Int {
        messages.count
    }

    func message(at index: Int) -> MMessage? {
        guard index >= 0, index < messages.count else { return nil }
        return messages[index]
    }

    func insertNewMessage(_ message: MMessage) {
        guard !messages.contains(message) else { return }

        messages.append(message)
        messages.sort()

        DispatchQueue.main.async {
            self.delegate?.messagesDidUpdate()
        }
    }

    func sendMessage(_ text: String) {
        isLoading = true

        let message = MMessage(user: user, content: text)
        FirestoreService.shared.sendMessage(chat: chat, message: message) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Private
    private func setupMessageListener() {
        messageListener = ListenerService.shared.messageObserve(chat: chat) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                self.insertNewMessage(message)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.errorDidOccur(error: error.localizedDescription)
                }
            }
        }
    }
}

