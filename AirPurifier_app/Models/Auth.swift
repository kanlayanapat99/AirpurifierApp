//
//  Auth.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 23/7/2568 BE.
//

import Foundation
import Combine
import KeychainAccess

class Auth: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    
    private let keychain = Keychain(service: "com.Airpurifierapp.iotTest1.AirPurifier-app")
    private var authStore: AuthStore

    init(authStore: AuthStore) {
        self.authStore = authStore
        
        if let storedEmail = keychain["userEmail"] {
            self.email = storedEmail
            self.isAuthenticated = true
        }
    }

    func isEmailAllowed(_ email: String) -> Bool {
        authStore.isEmailAllowed(email)
    }

    func login(with email: String) {
        guard isEmailAllowed(email) else {
            print("❌ Email not allowed")
            return
        }
        self.email = email
        self.isAuthenticated = true
        keychain["userEmail"] = email
    }

    func logout() {
        self.email = ""
        self.isAuthenticated = false
        try? keychain.remove("userEmail")
    }
}
