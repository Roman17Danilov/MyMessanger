//
//  MMessage.swift
//  MyMessanger
//
//  Created by Roman on 25.02.2026.
//

import UIKit
import FirebaseFirestore
import MessageKit
import CryptoKit

struct Sender: MessageKit.SenderType {
    let senderId: String
    let displayName: String
}

struct MMessage: Hashable, MessageType {
    
    let content: String
    var sentDate: Date
    let id: String?
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var kind: MessageKit.MessageKind {
        return .text(content)
    }
    
    var sender: any MessageKit.SenderType
    
    init(user: MUser, content: String) {
        self.content = content
        sender = Sender(senderId: user.id, displayName: user.username)
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentData = data["created"] as? Timestamp else { return nil }
        guard let senderId = data["senderId"] as? String else { return nil }
        guard let senderUsername = data["senderUsername"] as? String else { return nil }
        guard let content = data["content"] as? String else { return nil }
        
        self.id = document.documentID
        self.sentDate = sentData.dateValue()
        sender = Sender(senderId: senderId, displayName: senderUsername)
        self.content = content
    }
    
    var representation: [String: Any] {
        let rep: [String: Any] = [
            "created": Timestamp(date: sentDate),
            "senderId": sender.senderId,
            "senderUsername": sender.displayName,
            "content": content
        ]
        
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

extension MMessage: Comparable {
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
