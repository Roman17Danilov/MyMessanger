//
//  SetupProfileViewModel.swift
//  MyMessanger
//
//  Created by Roman on 18.03.2026.
//

import UIKit
import FirebaseAuth

class SetupProfileViewModel {
    private let currentUser: MUser

    var fullName = ""
    var aboutMe = ""
    var sex = "Male"
    var selectedImage: UIImage?

    var onSaveSuccess: ((MUser) -> Void)?
    var onSaveError: ((String) -> Void)?
    var onButtonStateChange: (() -> Void)?

    var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(currentUser: MUser) {
        self.currentUser = currentUser
        self.fullName = currentUser.username
    }

    func saveProfile() {
        guard isFormValid else { return }

        onButtonStateChange?()

        FirestoreService.shared.saveProfileWith(
            id: currentUser.id,
            email: currentUser.email,
            username: fullName,
            avatarImage: selectedImage,
            description: aboutMe,
            sex: sex
        ) { [weak self] result in
            switch result {
            case .success(let mUser):
                self?.onSaveSuccess?(mUser)
            case .failure(let error):
                self?.onSaveError?(error.localizedDescription)
            }
        }
    }

    func updateSex(_ sex: String) {
        self.sex = sex
    }
}
