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
    
    func makeLoginRequest(email: String, password: String, completion: (_ success: Bool, _ error: Error?)->Void) {
        
        let e: Error?=nil
        
        self.requestService.makeLoginRequest(email: email, password: password) { (response) in
            //
        }
        
        completion(isLoggedIn,e)
    }
}
