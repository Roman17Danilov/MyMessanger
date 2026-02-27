//
//  MChat.swift
//  MyMessanger
//
//  Created by Roman on 20.02.2026.
//

import UIKit

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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
}
