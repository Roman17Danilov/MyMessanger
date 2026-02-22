//
//  Validators.swift
//  MyMessanger
//
//  Created by Roman on 21.02.2026.
//

import Foundation

class Validators {
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let password = password,
              let confirmPassword = confirmPassword,
              let email = email,
              password != "",
              confirmPassword != "",
              email != "" else { return false }
        
        return true
    }
    
    static func isFilled(username: String?, description: String?, sex: String?) -> Bool {
        guard let description = description,
              let sex = sex,
              let username = username,
              description != "",
              sex != "",
              description != "" else { return false }
        
        return true
    }
    
    static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        
        return predicate.evaluate(with: text)
    }
    
    static func isSimpleEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        return check(text: email, regEx: emailRegEx)
    }
}
