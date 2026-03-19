//
//  MVVMProfileViewController.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

import UIKit
import SDWebImage

class MVVMProfileViewController: UIViewController, ProfileViewModelDelegate {

    private let viewModel: ProfileViewModel

    private let containerView = UIView()
    private let imageView = UIImageView(image: UIImage(named: "human2"), contentMode: .scaleAspectFill)
    private let nameLabel = UILabel(text: "Peter Ben", font: .systemFont(ofSize: 20, weight: .light))
    private let aboutMeLabel = UILabel(text: "You have the opportunity to chat with the best man in the world!", font: .systemFont(ofSize: 16, weight: .light))
    private let myTextField = InsertableTextField()

    init(user: MUser) {
        self.viewModel = ProfileViewModel(user: user)
        super.init(nibName: nil, bundle: nil)

        nameLabel.text = viewModel.username
        aboutMeLabel.text = viewModel.description
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        viewModel.delegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        view.backgroundColor = .white

        customizeElements()
        setupConstraints()
        setupAvatarImage()
    }

    // MARK: - ProfileViewModelDelegate
    func profileDidUpdate() {
        DispatchQueue.main.async {
            self.nameLabel.text = self.viewModel.username
            self.aboutMeLabel.text = self.viewModel.description
        }
    }

    func errorDidOccur(error: String) {
        DispatchQueue.main.async {
            self.showAlert(with: "Error", end: error)
        }
    }

    func sendMessageDidSucceed(message: String, receiver: MUser) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                UIApplication.topViewController?.showAlert(
                    with: "Success!",
                    end: "Your message for \(receiver.username) were sent!"
                )
            }
        }
    }

    // MARK: - UI
    private func setupAvatarImage() {
        imageView.image = UIImage(named: "human2")
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true

        if let data = Data(base64Encoded: viewModel.avatarStringURL) {
            imageView.image = UIImage(data: data)
            imageView.backgroundColor = .clear
        }
    }

    private func customizeElements() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false

        aboutMeLabel.numberOfLines = 0

        containerView.backgroundColor = .mainWhite()
        containerView.layer.cornerRadius = 30

        if let button = myTextField.rightView as? UIButton {
            button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        }
    }

    @objc private func sendMessage() {
        guard let message = myTextField.text, !message.isEmpty else { return }
        viewModel.sendMessage(message: message)
    }

    // MARK: - Constraints
    func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(containerView)

        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(myTextField)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])

        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])

        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutMeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutMeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])

        NSLayoutConstraint.activate([
            myTextField.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            myTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            myTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            myTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

