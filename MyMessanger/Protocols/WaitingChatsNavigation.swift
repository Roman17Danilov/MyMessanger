//
//  WaitingChatsNavigation.swift
//  MyMessanger
//
//  Created by Roman on 27.02.2026.
//

import UIKit

protocol WaitingChatsNavigation: class {
    func removeWaitingChat(chat: MChat)
    func chatToActive(chat: MChat)
}
