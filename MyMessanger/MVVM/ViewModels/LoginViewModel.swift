//
//  LoginViewModel.swift
//  MyMessanger
//
//  Created by Roman on 18.03.2026.
//

import GoogleSignIn
import FirebaseAuth
import FirebaseCore

class LoginViewModel {
    private let authService: AuthServiceProtocol = AuthService.shared
    
    // MARK: - Input
    var email = ""
    var password = ""
    var isLoading = false
    
    // MARK: - Callbacks (твои)
    var onLoginSuccess: ((MUser?) -> Void)?
    var onLoginError: ((String) -> Void)?
    var onNavigateToSignUp: (() -> Void)?
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func googleButtonTapped(presentingVC: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            onLoginError?("Client ID not found")
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
                        self?.handleGoogleLogin(firebaseUser: firebaseUser)
                    case .failure(let error):
                        self?.onLoginError?(error.localizedDescription)
                    }
                }
            )
        }
    }
    
    func loginButtonTapped(email: String, password: String) {
        guard isFormValid else {
            onLoginError?("Заполните все поля")
            return
        }
        
        isLoading = true
        self.authService.login(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { result in
                    switch result {
                    case .success(let mUser):
                        self?.onLoginSuccess?(mUser)
                    case .failure:
                        self?.onLoginSuccess?(nil)
                    }
                }
            case .failure(let error):
                self?.onLoginError?(error.localizedDescription)
            }
        }
    }
    
    func signUpButtonTapped() {
        onNavigateToSignUp?()
    }
    
    private func handleGoogleLogin(firebaseUser: User) {
        FirestoreService.shared.getUserData(user: firebaseUser) { [weak self] result in
            switch result {
            case .success(let mUser):
                self?.onLoginSuccess?(mUser)
            case .failure:
                self?.onLoginError?("No profile found. Please sign up first.")
            }
        }
    }
}
