//
//  AuthViewModel.swift
//  MyMessanger
//
//  Created by Roman on 13.03.2026.
//

import GoogleSignIn
import FirebaseAuth
import FirebaseCore


class AuthViewModel {
    private let authService: AuthServiceProtocol = AuthService.shared
    
    var onNavigateToSignUp: (() -> Void)?
    var onNavigateToLogin: (() -> Void)?
    var onAuthSuccess: ((MUser?) -> Void)?
    var onAuthError: ((String) -> Void)?
    
    func googleButtonTapped(presentingVC: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            onAuthError?("Client ID not found")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] result, error in
            self?.authService.googleLogin(
                user: result?.user,
                error: error,
                completion: { result in
                    switch result {
                    case .success(let firebaseUser):
                        self?.handleSuccessfulAuth(firebaseUser: firebaseUser)
                    case .failure(let error):
                        self?.onAuthError?(error.localizedDescription)
                    }
                }
            )
        }
    }
    
    func emailButtonTapped() {
        onNavigateToSignUp?()
    }
    
    func loginButtonTapped() {
        onNavigateToLogin?()
    }
    
    private func handleSuccessfulAuth(firebaseUser: User) {
        FirestoreService.shared.getUserData(user: firebaseUser) { [weak self] result in
            switch result {
            case .success(let mUser):
                self?.onAuthSuccess?(mUser)
            case .failure:
                self?.onAuthSuccess?(nil)   
            }
        }
    }
}
