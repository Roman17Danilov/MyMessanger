//
//  MVVMAuthViewController.swift
//  MyMessanger
//
//  Created by Roman on 13.03.2026.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class MVVMAuthViewController: UIViewController {
    
    private let viewModel = AuthViewModel()
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sign up with")
    let alreadyOnboardLabel = UILabel(text: "Alerady onboard?")
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    let emailButton = UIButton(title: "Email", titleColor: .white, backgroundColor: .buttonDark())
    let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgroundColor: .white, isShadow: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🎨 ✅ MVVM РАБОТАЕТ! Архитектура: \(AppRouter.architecture)")
        setupBindings()
        setupUI()
    }
    
    private func setupBindings() {
        viewModel.onNavigateToSignUp = { [weak self] in
            self?.present(SignUpViewController(), animated: true)
        }
        
        viewModel.onNavigateToLogin = { [weak self] in
            self?.present(LoginViewController(), animated: true)
        }
        
        viewModel.onAuthSuccess = { [weak self] mUser in
            self?.handleAuthSuccess(mUser: mUser)
        }
        
        viewModel.onAuthError = { [weak self] error in
            self?.showAlert(with: "Error", end: error)
        }
    }
    
    private func setupUI() {

        googleButton.customizeGoogleButton()
        view.backgroundColor = .white
        setupConstraints()
        

        emailButton.addTarget(self, action: #selector(emailTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
    }
    
    @objc private func googleTapped() {
        viewModel.googleButtonTapped(presentingVC: self)
    }
    
    @objc private func emailTapped() {
        viewModel.emailButtonTapped()
    }
    
    @objc private func loginTapped() {
        viewModel.loginButtonTapped()
    }
    
    private func handleAuthSuccess(mUser: MUser?) {
        if let mUser = mUser {
            let mainTabBar = MainTabBarController(currentUser: mUser)
            mainTabBar.modalPresentationStyle = .fullScreen
            present(mainTabBar, animated: true)
        } else {
            if let firebaseUser = Auth.auth().currentUser {
                let newUser = MUser.from(firebaseUser: firebaseUser)
                present(SetupProfileViewController(currentUser: newUser), animated: true)
            }
        }
    }

}

extension MVVMAuthViewController {
    private func setupConstraints() {
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnboardLabel, button: loginButton)
        let stackView = UIStackView(arrangedSubviews: [googleView, emailView, loginView], axis: .vertical, spacing: 40)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 160),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
