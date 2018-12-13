//
//  biometricsService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 12/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit

protocol BiometricsDelegate {
    func biometricsSuccessfullyAuthenticated(isFirstLogin: Bool)
    func biometricsDidError(with message: String?, isFirstLogin: Bool)
}

class BiometricsAuthService {
    enum BiometricType {
        case None
        case TouchID
        case FaceID
    }
    
    private var context = LAContext()
    private let biometricsEnabledKey = ConfigurationsService.PhoneBookBundleID + ".biometricsEnabled"
    let touchIDOptInTitle = "Use Touch ID for login in the future?".localize
    let touchIDOptInMessage = "Touch ID makes Login more convenient. These Settings can be updated in the Account section.".localize
    let touchIDConfirmed = "Use Touch ID".localize
    let touchIDDeclined = "No Thanks".localize
    var delegate: BiometricsDelegate?
    
    var biometricType: BiometricType {
        get {
            var error: NSError?
            
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                print(error?.localizedDescription ?? "")
                return .None
            }
            
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .none:
                    return .None
                case .touchID:
                    return .TouchID
                case .faceID:
                    return .FaceID
                }
            } else {
                return .None
            }
        }
    }
    
    /**
     Text for enabling Touch ID vs. Face ID depending on context
     */
    var toggleTitleText : String {
        return self.makeBiometricsPrependedMessage("Enable", defaultText: "Biometrics Unavailable")
    }
    
    /**
     Messaging text for turning off 'Remember Me' in Touch ID vs. Face ID context
     */
    var biometricOptOutMessage : String {
        return self.makeBiometricsPrependedMessage("Turning off 'Remember Me' will disable", defaultText: self.biometricsFallbackMessage)
    }
    
    init(biometricsDelegate: BiometricsDelegate?=nil) {
        self.delegate = biometricsDelegate
    }
    
    /**
     Bool indicating the current device has biometrics capabilities
     */
    var biometricsAvailable: Bool {
        return self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    /**
     Bool indicating biometrics are available, and user has opted-in to use them for login
     */
    var biometricsEnabled : Bool {
        guard let enabled = UserDefaults.standard.value(forKey: self.biometricsEnabledKey) as? Bool else { return false }
        return enabled && self.biometricsAvailable
    }
    
    /**
     Image for Touch ID or Face ID switch
     */
    var biometricToggleImage : UIImage {
        switch self.biometricType {
        case .FaceID: return #imageLiteral(resourceName: "face_ID_Penn")
        default: return #imageLiteral(resourceName: "touchID")
        }
    }
    
    /**
     Sets Bool in UserDefaults indicating whether biometric authentication is enabled
     */
    func toggleBiometrics(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: self.biometricsEnabledKey)
    }
    
    /**
     Conditionally attempt authenticating user with biometrics
     */
    func attemptBiometricsAuthentication() {
        if self.biometricsEnabled {
            self.utilizeBiometricAuthentication()
            return
        }
    }
    
    /**
     Authenticate user using biometrics
     */
    func utilizeBiometricAuthentication(isfirstLogin: Bool = false) {
        self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
        localizedReason: self.biometricsLoginMessage) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    self.delegate?.biometricsSuccessfullyAuthenticated(isFirstLogin: isfirstLogin)
                }
            } else {
                var message: String?=nil
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = self.biometricsFailedMessage
                case LAError.userCancel?, LAError.userFallback?: break
                default:
                    message = self.biometricsFallbackMessage
                }
                DispatchQueue.main.async {
                    self.delegate?.biometricsDidError(with: message, isFirstLogin: isfirstLogin)
                }
            }
        }
        // Reset context to always prompt for login credentials
        self.context = LAContext()
    }
}

private extension BiometricsAuthService {
    /**
     Message for failed biometric login
    */
    var biometricsFailedMessage : String { return "There was a problem verifying your identity.".localize }
    
    /**
     Message indicating biometric login in-progress
    */
    var biometricsLoginMessage : String {
        return self.makeBiometricsPrependedMessage("Logging in with", defaultText: self.biometricsFallbackMessage)
    }
    
    /**
     Fallback message indicating biometrics not authorized on device
    */
    var biometricsFallbackMessage : String {
        let baseText = "not authorized for use."
        return self.makeBiometricsAppendedMessage(baseText, defaultText: "Biometrics \(baseText)")
    }
    
    /**
     Message indicating biometrics unavailable on device
    */
    var biometricsUnavailableMessage : String {
        return self.makeBiometricsAppendedMessage("is not available on this device.", defaultText: self.biometricsFallbackMessage)
    }
    
    /**
     Convenience method for making custom, context-based phrases appended at the end of a message
     - parameters:
        - baseText: Phrase that will go at the end of the message
        - defaultText: Phrase that will appear if biometrics unavailable
    */
    func makeBiometricsAppendedMessage(_ baseText: String, defaultText: String) -> String {
        switch biometricType {
        case .TouchID: return "Touch ID \(baseText)".localize
        case .FaceID: return "Face ID \(baseText)".localize
        default: return defaultText
        }
    }
    
    /**
     Convenience method for making custom, context-based phrases prepended at the beginning of a message
     - parameters:
         - baseText: Phrase that will go at the beginning of the message
         - defaultText: Phrase that will appear if biometrics unavailable
     */
    func makeBiometricsPrependedMessage(_ baseText: String, defaultText: String) -> String {
        switch self.biometricType {
        case .TouchID: return "\(baseText) Touch ID".localize
        case .FaceID: return "\(baseText) Face ID".localize
        default: return defaultText
        }
    }
}
