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
    func touchIDDidError(with message: String?)
}

class TouchIDAuthService {
    private let touchIDEnabledKey = "touchIDEnabled"
    private let context = LAContext()
    var delegate: TouchIDDelegate?
    
    init(touchIDDelegate: TouchIDDelegate?=nil) {
        self.delegate = touchIDDelegate
    }
    
    /**
     Bool indicating user has opted-in to use TouchID for Login
    */
    var touchIDEnabled : Bool {
        guard let enabled = UserDefaults.standard.value(forKey: self.touchIDEnabledKey) as? Bool else { return false }
        return enabled
    }
    
    /**
     Bool indicating the current device has TouchID capabilities
    */
    var touchIDAvailable: Bool {
        return self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func toggleTouchID(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: self.touchIDEnabledKey)
    }
    
    func attemptTouchIDAuthentication() {
        if self.touchIDEnabled {
            self.authenticateUser()
        }
    }
    
    func authenticateUser() {
        guard self.touchIDAvailable else {
            self.delegate?.touchIDDidError(with: "Touch ID is not available on this device.".localize)
            return
        }
        
        self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
           localizedReason: "Logging in with Touch ID".localize) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    self.delegate?.touchIDSuccessfullyAuthenticated()
                }
            } else {
                var message: String?=nil
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity.".localize
                case LAError.userCancel?, LAError.userFallback?: break
                default:
                    message = "Touch ID may not be configured".localize
                }
                DispatchQueue.main.async {
                    self.delegate?.touchIDDidError(with: message)
                }
            }
        }
    }
}
