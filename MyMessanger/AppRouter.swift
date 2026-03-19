//
//  AppRouter.swift
//  MyMessanger
//
//  Created by Roman on 13.03.2026.
//

//
// AppRouter.swift
// MyMessanger
//

import UIKit

enum AppArchitecture {
    case mvc, mvvm
}

class AppRouter {
    static var architecture: AppArchitecture = .mvvm

    // Auth
    static func authScreen() -> UIViewController {
        switch architecture {
        case .mvc:
            return AuthViewController()
        case .mvvm:
            return MVVMAuthViewController()
        }
    }

    // Login
    static func loginScreen() -> UIViewController {
        switch architecture {
        case .mvc:
            return LoginViewController()
        case .mvvm:
            return MVVMLoginViewController()
        }
    }

    // Setup Profile
    static func setupProfileScreen(user: MUser) -> UIViewController {
        switch architecture {
        case .mvc:
            return SetupProfileViewController(currentUser: user)
        case .mvvm:
            return MVVMSetupProfileViewController(currentUser: user)
        }
    }

    // People
    static func peopleScreen(user: MUser) -> UIViewController {
        switch architecture {
        case .mvc:
            return PeopleViewController(currentUser: user)
        case .mvvm:
            return MVVMPeopleViewController(currentUser: user)
        }
    }

    // List (Chats)
    static func listScreen(user: MUser) -> UIViewController {
        switch architecture {
        case .mvc:
            return ListViewController(currentUser: user)
        case .mvvm:
            return MVVMListViewController(currentUser: user)
        }
    }

    // ChatRequest
    static func chatRequestScreen(chat: MChat) -> UIViewController {
        switch architecture {
        case .mvc:
            return ChatRequestViewController(chat: chat)
        case .mvvm:
            return MVVMChatRequestViewController(chat: chat)
        }
    }

    // Chat
    static func chatScreen(user: MUser, chat: MChat) -> UIViewController {
        switch architecture {
        case .mvc:
            return ChatsViewController(user: user, chat: chat)
        case .mvvm:
            return MVVMChatViewController(user: user, chat: chat)
        }
    }

    // Profile
    static func profileScreen(user: MUser) -> UIViewController {
        switch architecture {
        case .mvc:
            return ProfileViewController(user: user)
        case .mvvm:
            return MVVMProfileViewController(user: user)
        }
    }

    // Main TabBarController
    static func mainTabBar(for user: MUser) -> UIViewController {
        return MainTabBarController(currentUser: user)
    }
}

