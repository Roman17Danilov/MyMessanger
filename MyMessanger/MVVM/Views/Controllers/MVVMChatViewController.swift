//
//  MVVMChatViewController.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

internal import InputBarAccessoryView
import MessageKit
import UIKit

class MVVMChatViewController: MessagesViewController, ChatViewModelDelegate {
    
    private let chat: MChat
    private let user: MUser
    private let viewModel: ChatViewModel

    init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = chat
        self.viewModel = ChatViewModel(chat: chat, user: user)
        super.init(nibName: nil, bundle: nil)

        title = chat.friendUsername
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        messagesCollectionView.backgroundColor = .mainWhite()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self

        configureMessageInputBar()
    }

    // MARK: - Private
    private func configureMessageInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = .gray
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)

        messageInputBar.layer.shadowColor = UIColor.systemGray.cgColor
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)

        configureSendButton()
    }

    private func configureSendButton() {
        guard let imageData = UIImage(named: "Sent")?.pngData() else { return }
        let image2x = UIImage(data: imageData, scale: 2.0)!

        let button = messageInputBar.sendButton
        button.title = ""
        var config = button.configuration ?? UIButton.Configuration.plain()
        config.image = image2x
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        config.baseForegroundColor = .white
        button.configuration = config
        button.layer.masksToBounds = true

        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: true)
    }

    // MARK: - ChatViewModelDelegate
    func messagesDidUpdate() {
        messagesCollectionView.reloadData()

        if let lastMessage = viewModel.message(at: viewModel.messageCount - 1),
           messagesCollectionView.isAtBottom {
            messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

    func errorDidOccur(error: String) {
        DispatchQueue.main.async {
            self.showAlert(with: "Error", end: error)
        }
    }
}

// MARK: - MessagesDataSource
extension MVVMChatViewController: MessagesDataSource {

    var currentSender: SenderType {
        Sender(senderId: user.id, displayName: user.username)
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let message = viewModel.message(at: indexPath.item) else {
            fatalError("Index out of bounds")
        }
        return message
    }

    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        viewModel.messageCount
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        1
    }

    func cellTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath
    ) -> NSAttributedString? {
        if indexPath.item % 4 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }
        return nil
    }
}

// MARK: - MessagesLayoutDelegate
extension MVVMChatViewController: MessagesLayoutDelegate {

    func footerViewSize(
        for section: Int,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGSize {
        CGSize(width: 0, height: 8)
    }

    func cellTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        if indexPath.item % 4 == 0 {
            return 30
        }
        return 0
    }
}

// MARK: - MessagesDisplayDelegate
extension MVVMChatViewController: MessagesDisplayDelegate {

    func backgroundColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        isFromCurrentSender(message: message) ? .white : UIColor.systemPurple
    }

    func textColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        isFromCurrentSender(message: message)
            ? UIColor(white: 0.3, alpha: 1.0)
            : .white
    }

    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        avatarView.isHidden = true
    }

    func avatarSize(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGSize? {
        .zero
    }

    func messageStyle(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
        .bubble
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension MVVMChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        viewModel.sendMessage(text)
        inputBar.inputTextView.text = ""
    }
}
