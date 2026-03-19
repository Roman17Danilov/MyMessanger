//
//  MVVMLoginViewController.swift
//  MyMessanger
//
//  Created by Roman on 18.03.2026.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class MVVMLoginViewController: UIViewController {
    let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir26())
    let loginWithLabel = UILabel(text: "Login with")
    let orLabel = UILabel(text: "or")
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let needAnAccountLabel = UILabel(text: "Need an account?")
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    let loginButton = UIButton(title: "Login", titleColor: .white, backgroundColor: .buttonDark())
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🎨 MVVM Login! Архитектура: \(AppRouter.architecture)")
        setupBindings()
        setupUI()
        setupTextFieldValidation()
    }

    private func setupTextFieldValidation() {
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    @objc private func textFieldChanged() {
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        updateLoginButton()
    }

    private func updateLoginButton() {  
        let isValid = viewModel.isFormValid && !viewModel.isLoading
        loginButton.isEnabled = isValid
        loginButton.alpha = viewModel.isLoading ? 0.6 : 1.0
        
        loginButton.setTitle(
            viewModel.isLoading ? "Logging in..." : "Login",
            for: .normal
        )
    }

    
    private func setupBindings() {
        viewModel.onLoginSuccess = { [weak self] mUser in
            self?.handleLoginSuccess(mUser: mUser)
        }
        viewModel.onLoginError = { [weak self] error in
            self?.showAlert(with: "Error", end: error)
        }
        viewModel.onNavigateToSignUp = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        googleButton.customizeGoogleButton()
        setupConstraints()
        
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
    }
    
    @objc private func googleTapped() {
        viewModel.googleButtonTapped(presentingVC: self)
    }
    
    @objc private func loginTapped() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        viewModel.loginButtonTapped(email: email, password: password)
    }

    
    @objc private func signUpTapped() {
        viewModel.signUpButtonTapped()
    }
    
    private func handleLoginSuccess(mUser: MUser?) {
        if let mUser = mUser {
            let mainTabBar = MainTabBarController(currentUser: mUser)
            mainTabBar.modalPresentationStyle = .fullScreen
            present(mainTabBar, animated: true)
        } else {
            guard let firebaseUser = Auth.auth().currentUser else { return }
            let newMUser = MUser.from(firebaseUser: firebaseUser)
            present(SetupProfileViewController(currentUser: newMUser), animated: true)
        }
    }

}

extension MVVMLoginViewController {
    private func setupConstraints() {
        let loginWithView = ButtonFormView(label: loginWithLabel, button: googleButton)
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [loginWithView, orLabel, emailStackView, passwordStackView, loginButton], axis: .vertical, spacing: 40)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
