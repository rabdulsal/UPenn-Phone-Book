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
    static var IsLoggedInNotification = ConfigurationsService.PhoneBookBundleID + ".IsLoggedInNotification"
    var isLoggedIn : Bool { return AuthenticationService.isAuthenticated }
    var requestService = NetworkRequestService()
    var loginDelegate: LoginServiceDelegate
    var shouldAutoLogin : Bool { return AuthenticationService.shouldAutoLogin }
    var shouldAutoFill : Bool { return AuthenticationService.shouldAutoFill }
    var isFirstLogin : Bool { return AuthenticationService.isFirstLogin }
    private let genericLoginError = "Sorry an error occurred while attempting Login. Please try again."
    private let statusCodeError = "Something went wrong getting a Status Code for your Login Request. Please try again."
    private let autoLoginError = "Something went wrong attempting Auto-Login - could not retrieve Username & Password. Please try again."
    private let usernamePasswordError = "You have entered an incorrect Username or Password. Please try again."
    
    init(loginDelegate: LoginServiceDelegate) {
        self.loginDelegate = loginDelegate
    }
    
    func makeLoginRequest(email: String, password: String) {
        
        self.requestService.makeLoginRequest(email: email, password: password) { (response) in
            
            guard let statusCode = response.response?.statusCode else {
                self.loginDelegate.didFailToLoginUser(errorStr: self.statusCodeError)
                return
            }
            
            if statusCode == 200 {
                let json = response.result.value as? Dictionary<String,Any>
                guard let token = json?["access_token"] as? String else {
                   self.loginDelegate.didFailToLoginUser(errorStr: self.genericLoginError)
                    return
                }
                AuthenticationService.storeAuthenticationCredentials(
                    token: token,
                    email: email,
                    password: password)
                self.loginDelegate.didSuccessfullyLoginUser()
                return
            }
            
            // TODO: Add logic for expired JWT token
            
            // Generic Error
            self.loginDelegate.didFailToLoginUser(errorStr: self.usernamePasswordError)
        }
    }
    
    func cacheLoginCredentials(username: String, password: String) {
        AuthenticationService.cacheAuthenticationCredentials(username: username, password: password)
    }
    
    func authenticationAutoFillCheck() {
        if shouldAutoFill {
            AuthenticationService.checkAuthenticationCache { (username, password) in
                if let u = username, let p = password {
                    self.loginDelegate.didReturnAutoFillCredentials(username: u, password: p)
                }
            }
        }
    }
    
    func attemptSilentLogin() {
        AuthenticationService.checkAuthenticationCache { (username, password) in
            guard let u = username, let p = password else {
                self.loginDelegate.didFailToLoginUser(errorStr: self.autoLoginError)
                return
            }
            self.makeLoginRequest(email: u, password: p)
        }
    }
    
    func toggleShouldAutoLogin(_ autoLogin: Bool) {
        AuthenticationService.toggleShouldAutoLogin(autoLogin)
    }
    
    func toggleShouldAutoFill(_ autoFill: Bool) {
        AuthenticationService.toggleShouldAutoFill(autoFill)
    }
    
    func checkFirstLogin(completion:((_ isFirstLogin: Bool)->Void)) {
        AuthenticationService.checkFirstLogin(completion: completion)
    }
    
    func setFirstLogin() {
        AuthenticationService.setFirstLogin()
    }
    
    func logout() {
        AuthenticationService.logout()
    }
}
