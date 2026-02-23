//
//  FirestoreService.swift
//  MyMessanger
//
//  Created by Roman on 22.02.2026.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToUser))
                    
                    return 
                }
                
                completion(.success(mUser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func saveProfileWith(id: String, email: String, username: String?, avatarImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        
        guard Validators.isFilled(username: username, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        let avatarBase64 = StorageService.shared.uploadPhoto(avatarImage)
        
        guard avatarImage != UIImage(#imageLiteral(resourceName: "avatar"))  else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        let mUser = MUser(
            username: username!,
            email: email,
            avatarStringURL: avatarBase64 ?? "Not exist",
            description: description!,
            sex: sex!,
            id: id
        )
        
        usersRef.document(mUser.id).setData(mUser.representation) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(mUser))
            }
        }
    }

}
