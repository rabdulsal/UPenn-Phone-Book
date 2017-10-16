//
//  LoginService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/15/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class LoginService {
    
    var isLoggedIn = false
    var requestService = NetworkRequestService()
    
    func makeLoginRequest(email: String, password: String, completion: @escaping (_ success: Bool, _ error: Error?)->Void) {
        
        let e: Error?=nil
        
        self.requestService.makeLoginRequest(email: email, password: password) { (response) in
            
            guard let statusCode = response.response?.statusCode else {
                // TODO: Pass up some general error about Status Code
                return
            }
            
            if statusCode == 200 {
                let json = response.result.value as? Dictionary<String,Any>
                if let token = json?["access_token"] as? String {
                    AuthenticationService.storeAuthenticationToken(token: token)
                    self.isLoggedIn = true
                }
            }
            completion(self.isLoggedIn,e)
        }
    }
}
