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
}
