//
//  MMessage.swift
//  MyMessanger
//
//  Created by Roman on 25.02.2026.
//

import UIKit
import FirebaseFirestore

struct MMessage: Hashable {
    let content: String
    let senderId: String
    let senderUsername: String
    var sentDate: Date
    let id: String?
    
    init(user: MUser, content: String) {
        self.content = content
        senderId = user.id
        senderUsername = user.username
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
        self.senderId = senderId
        self.senderUsername = senderUsername
        self.content = content
    }
    
    var representation: [String: Any] {
        let rep: [String: Any] = [
            "created": Timestamp(date: sentDate),
            "senderId": senderId,
            "senderUsername": senderUsername,
            "content": content
        ]
        
        return rep
    }
}
