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
        
        let e: Error?=nil
        
        self.requestService.makeLoginRequest(email: email, password: password) { (response) in
            
            guard let statusCode = response.response?.statusCode else {
                self.loginDelegate.didFailToLoginUser(errorStr: self.genericLoginError)
                return
            }
            
            if statusCode == 200 {
                let json = response.result.value as? Dictionary<String,Any>
                if let token = json?["access_token"] as? String {
                    AuthenticationService.storeAuthenticationToken(token: token)
                    self.isLoggedIn = true
                }
                self.loginDelegate.didSuccessfullyLoginUser()
            }
            
            self.loginDelegate.didFailToLoginUser(errorStr: self.genericLoginError)
            // TODO: Fire successful delegate
        }
    }
    
    func checkAuthenticationCache() {
        AuthenticationService.checkAuthenticationCache { (username, password, error) in
            if let e = error {
                self.loginDelegate.didFailToLoginUser(errorStr: "Sorry, something went weirdly wrong.")
                return
                
            }
            
            guard
                let u = username,
                let p = password else {
                    self.loginDelegate.didFailToLoginUser(errorStr: "Sorry, something went weirdly wrong.")
                    return
            }
            self.makeLoginRequest(email: u, password: p)
        }
    }
}
