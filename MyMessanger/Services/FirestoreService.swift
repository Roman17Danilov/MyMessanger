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
    
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    var currentUser: MUser!
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToUser))
                    
                    return 
                }
                self.currentUser = mUser
                
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

    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        let message = MMessage(user: currentUser, content: message)
        let chat = MChat(friendUsername: currentUser.username, friendUserImageString: currentUser.avatarStringURL, lastMessage: message.content, friendId: currentUser.id)
        
        reference.document(currentUser.id).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                
                return
            }
            
            messageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
    func deleteWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
            }
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    
                    let messageRef = reference.document(documentId)
                    messageRef.delete { error in
                        if let error = error {
                            completion(.failure(error))
                            
                            return
                        }
                        
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages = [MMessage]()
        
        reference.getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                
                return
            }
            
            for document in querySnapshot!.documents {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            
            completion(.success(messages))
        }
    }
}
