//
//  StorageService.swift
//  MyMessanger
//
//  Created by Roman on 23.02.2026.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageService {
    static let shared = StorageService()
    
    func uploadPhoto(_ image: UIImage?) -> String? {
        guard let image = image else { return nil }
        return image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
    }
    
    static func downloadImage(base64String: String?) -> UIImage? {
        guard let base64 = base64String,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
}
