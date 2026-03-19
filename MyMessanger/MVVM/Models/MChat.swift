//
//  MChat.swift
//  MyMessanger
//
//  Created by Roman on 20.02.2026.
//

import UIKit
import FirebaseFirestore

struct MChat: Hashable, Decodable {
    var friendUsername: String
    var friendUserImageString: String
    var lastMessage: String
    var friendId: String
    
    var representation: [String: Any] {
        var rep = ["friendUsername": friendUsername]
        rep["friendUserImageString"] = friendUserImageString
        rep["lastMessage"] = lastMessage
        rep["friendId"] = friendId
        
        return rep
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let friendUsername = data["friendUsername"] as? String,
              let friendUserImageString = data["friendUserImageString"] as? String,
              let lastMessage = data["lastMessage"] as? String,
              let friendId = data["friendId"] as? String else { return nil }
        
        self.friendUsername = friendUsername
        self.friendId = friendId
        self.lastMessage = lastMessage
        self.friendUserImageString = friendUserImageString
    }
    
    init(friendUsername: String, friendUserImageString: String, lastMessage: String, friendId: String) {
        self.friendId = friendId
        self.friendUsername = friendUsername
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
}
