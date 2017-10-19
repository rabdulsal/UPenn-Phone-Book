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
    
    static func storeAuthenticationCredentials(
        token: String,
        email: String,
        password: String) {
        self.authToken = token
        self.isAuthenticated = true
        
        // Check if
        guard let _ = UserDefaults.standard.value(forKey: "hasLoginKey") else {
            self.cacheAuthenticationCredentials(username: email, password: password)
            return
        }
    }
    
    static func cacheAuthenticationCredentials(username: String, password: String) {
        
        UserDefaults.standard.setValue(username, forKey: "username")
        
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
        
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
    }
    
    static func checkAuthenticationCache(completion:(_ username: String?, _ password: String?)->Void) {
        
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else {
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
}
