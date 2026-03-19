//
//  AuthServiceProtocol.swift
//  MyMessanger
//
//  Created by Roman on 13.03.2026.
//

import FirebaseAuth
import GoogleSignIn

protocol AuthServiceProtocol {
    func googleLogin(user: GIDGoogleUser!, error: Error!, completion: @escaping (Result<User, Error>) -> Void)
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void)
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping (Result<User, Error>) -> Void)
}


extension AuthService: AuthServiceProtocol { }
