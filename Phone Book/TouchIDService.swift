//
//  TouchIDService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 12/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import LocalAuthentication

protocol TouchIDDelegate {
    func touchIDSuccessfullyAuthenticated()
    func touchIDDidError(with message: String)
}

class TouchIDAuthService {
    
    let context = LAContext()
    var delegate: TouchIDDelegate?
    
    init(touchIDDelegate: TouchIDDelegate) {
        self.delegate = touchIDDelegate
    }
    
    func canEvaluatePolicy() -> Bool {
        return self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser() {
        guard canEvaluatePolicy() else {
            self.delegate?.touchIDDidError(with: "Touch ID is not available on this device.")
            return
        }
        
        self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
           localizedReason: "Logging in with Touch ID") { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    self.delegate?.touchIDSuccessfullyAuthenticated()
                }
            } else {
                let message: String
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    message = "You pressed cancel."
                case LAError.userFallback?:
                    message = "You pressed password."
                default:
                    message = "Touch ID may not be configured"
                }
                self.delegate?.touchIDDidError(with: message)
            }
        }
    }
}
