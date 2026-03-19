//
//  SignUpViewModel.swift
//  MyMessanger
//
//  Created by Roman on 18.03.2026.
//

import Foundation
import FirebaseAuth

class SignUpViewModel: NSObject {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var fullName = ""
    var isLoading = false {
        didSet { updateButtonState?() }
    }
    var errorMessage: String? {
        didSet { showError?(errorMessage) }
    }
    
    var updateButtonState: (() -> Void)?
    var showError: ((String?) -> Void)?
    var signUpComplete: ((User) -> Void)?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        super.init()
    }
    
    var isValidEmail: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    var isPasswordValid: Bool {
        !password.isEmpty && password.count >= 6 && password == confirmPassword
    }
    
    var isFormValid: Bool {
        isValidEmail && isPasswordValid
    }
    
    func signUp() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        authService.register(
            email: email,
            password: password,
            confirmPassword: confirmPassword
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.signUpComplete?(user) 
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
