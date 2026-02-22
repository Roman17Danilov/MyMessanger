//
//  AuthViewController.swift
//  MyMessanger
//
//  Created by Roman on 20.02.2026.
//

import UIKit
import GoogleSignIn

class AuthViewController: UIViewController {
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sign up with")
    let alreadyOnboardLabel = UILabel(text: "Alerady onboard?")
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    let emailButton = UIButton(title: "Email", titleColor: .white, backgroundColor: .buttonDark())
    let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgroundColor: .white, isShadow: true)
    let signUpVC = SignUpViewController()
    let loginVC = LoginViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleButton.customizeGoogleButton()
        
        view.backgroundColor = .white
        
        setupConstraints()
        
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        
        signUpVC.delegate = self
        loginVC.delegate = self
    }
    
    @objc private func googleButtonTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            AuthService.shared.googleLogin(user: result?.user, error: error) { result in
                switch result {
                case .success(let firebaseUser):
                    self?.handleSuccessfulAuth(firebaseUser: firebaseUser)
                case .failure(let error):
                    self?.showAlert(with: "Error", end: error.localizedDescription)
                }
            }
        }
    }

    private func handleSuccessfulAuth(firebaseUser: User) {
        FirestoreService.shared.getUserData(user: firebaseUser) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let mUser):
                self.showAlert(with: "Successful", end: "You have been registered") {
                    let mainTabBar = MainTabBarController(currentUser: mUser)
                    
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.present(mainTabBar, animated: true)
                }
            case .failure:
                self.showAlert(with: "Successful", end: "You have been registered") {
                    self.present(SetupProfileViewController(currentUser: firebaseUser), animated: true)
                }
            }
        }
    }


    
    @objc private func emailButtonTapped() {
        print(#function)
        
        present(signUpVC, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        print(#function)
        
        present(loginVC, animated: true)
    }
}

// MARK: - Setup constraints
extension AuthViewController {
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

extension AuthViewController: AuthNavigatingDelegate {
    func toLoginVC() {
        present(loginVC, animated: true)
    }
    
    func toSignUpVC() {
        present(signUpVC, animated: true)
    }
    
    
}
// MARK: - SwiftUI
import SwiftUI
import FirebaseCore
import FirebaseAuth

struct AuthVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = AuthViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<AuthVCProvider.ContainerView>) -> AuthViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: AuthVCProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<AuthVCProvider.ContainerView>) {
            
        }
    }
}


