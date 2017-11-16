//
//  AutheticationService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/15/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class AuthenticationService {
    
    private(set) static var isAuthenticated = false
    private(set) static var authToken: String?
    private static let hasLoginKey = "hasLoginKey"
    private static let autoLoginKey = "shouldAutoLogin"
    private static let usernameKey = "username"
    static var shouldAutoLogin : Bool {
        guard let autoLogin = UserDefaults.standard.value(forKey: self.autoLoginKey) as? Bool else { return false }
        return autoLogin
    }
    
    static func storeAuthenticationCredentials(
        token: String,
        email: String,
        password: String) {
        self.authToken = token
        self.isAuthenticated = true
        
        // Check if key has already been stored
        guard let _ = UserDefaults.standard.value(forKey: self.hasLoginKey) else {
            // If not previously stored, then store credentials into keychain
            self.cacheAuthenticationCredentials(username: email, password: password)
            return
        }
    }
    
    static func cacheAuthenticationCredentials(username: String, password: String) {
        
        UserDefaults.standard.setValue(username, forKey: self.usernameKey)
        
        do {
            
            // This is a new account, create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            // Save the password for the new item.
            try passwordItem.savePassword(password)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: self.hasLoginKey)
    }
    
    static func checkAuthenticationCache(completion:(_ username: String?, _ password: String?)->Void) {
        
        guard let username = UserDefaults.standard.value(forKey: self.usernameKey) as? String else {
            completion(nil,nil)
            return
        }
        
        do {
            let passwordItem = KeychainPasswordItem(
                service: KeychainConfiguration.serviceName,
                account: username,
                accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            completion(username,keychainPassword)
        }
        catch {
            completion(nil,nil)
        }
    }
    
    static func toggleShouldAutoLogin(_ autoLogin: Bool) {
        UserDefaults.standard.set(autoLogin, forKey: self.autoLoginKey)
    }
}
