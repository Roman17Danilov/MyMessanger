//
//  ChatsViewController.swift
//  MyMessanger
//
//  Created by Roman on 28.02.2026.
//

import UIKit
import MessageKit
internal import InputBarAccessoryView
import FirebaseFirestore

class ChatsViewController: MessagesViewController {

    private var messages: [MMessage] = []
    private var messageListener: ListenerRegistration?
    private let user: MUser
    private let chat: MChat
    
    init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        
        title = chat.friendUsername
    }
    
    deinit {
        messageListener?.remove()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageInputBar()
        
        messagesCollectionView.backgroundColor = .mainWhite()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        messageListener = ListenerService.shared.messageObserve(chat: chat, completion: { result in
            switch result {
            case .success(let message):
                self.insertNewMessage(message: message)
            case .failure(let error):
                self.showAlert(with: "Error", end: error.localizedDescription)
            }
        })
    }
    
    private func insertNewMessage(message: MMessage) {
        guard !messages.contains(message) else { return }
        
        messages.append(message)
        messages.sort()
        
        messagesCollectionView.reloadData()
    }
}
    
extension ChatsViewController {
    func configureMessageInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = .gray
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5884958187)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        messageInputBar.layer.shadowColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2392156863, alpha: 1)
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
    }
    
    func configureSendButton() {
        guard let imageData = UIImage(named: "Sent")?.pngData() else { return }
        
        let button = messageInputBar.sendButton
        let image2x = UIImage(data: imageData, scale: 2.0)!
        
        button.title = ""
        
        var config = button.configuration ?? UIButton.Configuration.plain()
        
        config.image = image2x
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        config.baseForegroundColor = .white
        button.configuration = config
        button.layer.masksToBounds = true
        
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: true)
    }

}



extension ChatsViewController: MessagesDataSource {
    var currentSender: any MessageKit.SenderType {
        return Sender(senderId: user.id, displayName: user.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageKit.MessageType {
        return messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return 1
    }

}

extension ChatsViewController: MessagesLayoutDelegate {
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
}

extension ChatsViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : #colorLiteral(red: 0.8391960263, green: 0.5446689129, blue: 1, alpha: 1)
    }
    
    func textColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.3058650196, green: 0.30586496, blue: 0.3058649898, alpha: 1) : .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return .zero
    }
    
    func messageStyle(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
}

extension ChatsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MMessage(user: user, content: text)
        
        FirestoreService.shared.sendMessage(chat: chat, message: message) { result in
            switch result {
            case .success():
                self.messagesCollectionView.scrollToLastItem(animated: true)
            case .failure(let error):
                self.showAlert(with: "Error", end: error.localizedDescription)
            }
        }
        inputBar.inputTextView.text = ""
    }
}


