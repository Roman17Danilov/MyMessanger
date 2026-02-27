//
//  MMessage.swift
//  MyMessanger
//
//  Created by Roman on 25.02.2026.
//

import UIKit

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
    
    var representation: [String: Any] {
        var rep: [String: Any] = [
            "created": sentDate,
            "senderId": senderId,
            "senderUsername": senderUsername,
            "content": content
        ]
        
        return rep
    }
}
