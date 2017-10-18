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
    
    static func storeAuthenticationToken(token: String) {
        self.authToken = token
        // TODO: Store authToken into keyChain
    }
    
    static func reconcileAuthenticationCredentials(username: String, password: String, completion: (_ success:Bool, _ error:Error?)->Void) {
        
        if UserDefaults.standard.bool(forKey: "hasLoginKey") {
            // TODO: CODE MAY NOT BE NEEDED!
            guard username == UserDefaults.standard.value(forKey: "username") as? String else {
                return
            }
            
            do {
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                        account: username,
                                                        accessGroup: KeychainConfiguration.accessGroup)
                let keychainPassword = try passwordItem.readPassword()
//                return password == keychainPassword
            }
            catch {
                fatalError("Error reading password from keychain - \(error)")
            }
    
        } else {
            // LoginKey doesn't exist
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
    }
    
    static func checkAuthenticationCache(completion:(_ username: String?, _ password: String?, _ error: Error?)->Void) {
        
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else {
            // TODO: Return some generic Error in completion
            return
        }
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            completion(username,keychainPassword,nil)
        }
        catch {
            completion(nil,nil,error)
        }
    }
}
