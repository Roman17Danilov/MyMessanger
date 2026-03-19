//
//  ChatRequestViewModel.swift
//  MyMessanger
//
//  Created by Roman on 18.03.2026.
//

import UIKit

class ChatRequestViewModel {
    let chat: MChat
    
    var onAccept: (() -> Void)?
    var onDeny: (() -> Void)?
    
    init(chat: MChat) {
        self.chat = chat
    }
    
    func acceptChat() {
        onAccept?()
    }
    
    func denyChat() {
        onDeny?()
    }
}

