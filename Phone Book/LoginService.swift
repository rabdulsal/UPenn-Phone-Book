//
//  LoginService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/15/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

protocol LoginServiceDelegate {
    func didSuccessfullyLoginUser()
    func didReturnAutoFillCredentials(username: String, password: String)
    func didFailToLoginUser(errorStr: String)
}

class LoginService {
    
    var isLoggedIn = false
    var requestService = NetworkRequestService()
    var loginDelegate: LoginServiceDelegate
    let genericLoginError = "Sorry an error occurred while attempting Login. Please try again."
    
    init(loginDelegate: LoginServiceDelegate) {
        self.loginDelegate = loginDelegate
    }
    
    func makeLoginRequest(email: String, password: String) {
        
        self.requestService.makeLoginRequest(email: email, password: password) { (response) in
            
            guard let statusCode = response.response?.statusCode else {
                self.loginDelegate.didFailToLoginUser(errorStr: self.genericLoginError)
                return
            }
            
            if statusCode == 200 {
                let json = response.result.value as? Dictionary<String,Any>
                if let token = json?["access_token"] as? String {
                    AuthenticationService.storeAuthenticationCredentials(token: token, email: email, password: password)
                    self.isLoggedIn = true
                }
                self.loginDelegate.didSuccessfullyLoginUser()
                return
            }
            
            self.loginDelegate.didFailToLoginUser(errorStr: self.genericLoginError)
            // TODO: Fire successful delegate
        }
    }
    
    func authenticationAutoFillCheck() {
        AuthenticationService.checkAuthenticationCache { (username, password) in
            if let u = username, let p = password {
                self.loginDelegate.didReturnAutoFillCredentials(username: u, password: p)
            }
        }
    }
}
