//
//  MVVMSetupProfileViewController.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

import UIKit
import FirebaseAuth
import SDWebImage

class MVVMSetupProfileViewController: UIViewController {
    let welcomeLabel = UILabel(text: "Set up profile!", font: .avenir26())
    let fullImageView = AddPhotoView()
    let fullNameLabel = UILabel(text: "Full name")
    let aboutmeLabel = UILabel(text: "About me")
    let sexLabel = UILabel(text: "Sex")
    let fullNameTextField = OneLineTextField(font: .avenir20())
    let aboutMeTextField = OneLineTextField(font: .avenir20())
    let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Female")
    let goToChatsButton = UIButton(title: "Go to chats!", titleColor: .white, backgroundColor: .buttonDark(), cornerRadius: 4)

    private var viewModel: SetupProfileViewModel!
    private var selectedImage: UIImage?

    init(currentUser: MUser) {
        super.init(nibName: nil, bundle: nil)
        viewModel = SetupProfileViewModel(currentUser: currentUser)

        fullNameTextField.text = currentUser.username
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupBindings()
        setupUI()
        updateButtonState()
    }

    private func setupBindings() {
        viewModel.onSaveSuccess = { [weak self] mUser in
            self?.showAlert(with: "Successful!", end: "Have a nice chatting") {
                let mainTabBar = MainTabBarController(currentUser: mUser)
                mainTabBar.modalPresentationStyle = .fullScreen
                self?.present(mainTabBar, animated: true)
            }
        }

        viewModel.onSaveError = { [weak self] error in
            self?.showAlert(with: "Error", end: error)
        }

        viewModel.onButtonStateChange = { [weak self] in
            self?.updateButtonState()
        }
    }

    private func setupUI() {
        fullImageView.delegate = self

        setupConstraints()
        goToChatsButton.addTarget(self, action: #selector(goToChatsTapped), for: .touchUpInside)

        // Live‑валидация
        fullNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        aboutMeTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        sexSegmentedControl.addTarget(self, action: #selector(sexChanged), for: .valueChanged)
    }

    @objc private func textFieldChanged() {
        viewModel.fullName = fullNameTextField.text ?? ""
        viewModel.aboutMe = aboutMeTextField.text ?? ""
        updateButtonState()
    }

    @objc private func sexChanged() {
        let selectedTitle = sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex) ?? "Male"
        viewModel.updateSex(selectedTitle)
        updateButtonState()
    }

    @objc private func goToChatsTapped() {
        viewModel.selectedImage = selectedImage
        viewModel.saveProfile()
    }

    private func updateButtonState() {
        let isValid = viewModel.isFormValid
        goToChatsButton.isEnabled = isValid
        goToChatsButton.alpha = isValid ? 1.0 : 0.6
    }

    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

// MARK: - Constraints
extension MVVMSetupProfileViewController {
    private func setupConstraints() {
        let fullNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField],
                                            axis: .vertical,
                                            spacing: 0)
        let aboutMeStackView = UIStackView(arrangedSubviews: [aboutmeLabel, aboutMeTextField],
                                           axis: .vertical,
                                           spacing: 0)
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControl],
                                       axis: .vertical,
                                       spacing: 12)

        goToChatsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let stackView = UIStackView(arrangedSubviews: [
            fullNameStackView,
            aboutMeStackView,
            sexStackView,
            goToChatsButton
        ], axis: .vertical, spacing: 40)

        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(welcomeLabel)
        view.addSubview(fullImageView)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            fullImageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            fullImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: fullImageView.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

// MARK: - Delegates
extension MVVMSetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)

        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
            fullImageView.circleImageView.image = image
        }
    }
}

extension MVVMSetupProfileViewController: AddPhotoViewDelegate {
    func pickPhotoTapped() {
        presentImagePicker()
    }
}
