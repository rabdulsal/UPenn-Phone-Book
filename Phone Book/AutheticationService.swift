//
//  AutheticationService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/15/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class AuthenticationService {
    
    private(set) static var authToken: String?
    private static let autoLoginKey  = "shouldAutoLogin"
    private static let autoFillKey   = "shouldAutoFill"
    private static let usernameKey   = "username"
    private static let loginCountKey = "loginCountKey"
    private (set) static var isAuthenticated = false // TODO: Look to change this for better encapsulation
    static var shouldAutoLogin : Bool {
        guard let autoLogin = UserDefaults.standard.value(forKey: self.autoLoginKey) as? Bool else { return false }
        return autoLogin
    }
    
    static var shouldAutoFill : Bool {
        guard let autoFill = UserDefaults.standard.value(forKey: self.autoFillKey) as? Bool else { return false }
        return autoFill
    }
    
    static var isFirstLogin : Bool {
        return UserDefaults.standard.value(forKey: self.loginCountKey) as? Bool ?? true
    }
    
    static func storeAuthenticationCredentials(
        token: String,
        email: String,
        password: String) {
        self.authToken = token
        self.isAuthenticated = true
        
        // Check if shouldAutoFill, keychain-cache the in-coming credentials
        if self.shouldAutoFill {
            self.cacheAuthenticationCredentials(username: email, password: password)
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
    
    static func toggleShouldAutoFill(_ autoFill: Bool) {
        UserDefaults.standard.set(autoFill, forKey: self.autoFillKey)
    }
    
    static func checkFirstLogin(completion:((_ isFirstLogin: Bool)->Void)) {
        guard var _ = UserDefaults.standard.value(forKey: self.loginCountKey) as? Bool else {
            completion(true)
            return
        }
        completion(false)
    }
    
    static func setFirstLogin() {
        UserDefaults.standard.set(false, forKey: self.loginCountKey)
    }
    
    static func logout() {
        self.isAuthenticated = false
        self.authToken = nil
    }
}
