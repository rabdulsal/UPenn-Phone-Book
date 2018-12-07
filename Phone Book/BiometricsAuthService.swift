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
        switch self.biometricType {
        case .TouchID: return "Enable Touch ID"
        case .FaceID: return "Enable Face ID"
        case .None: return "Biometrics Unavailable"
        }
    }
    
    /**
     Messaging text for turning off 'Remember Me' in Touch ID vs. Face ID context
     */
    var biometricOptOutMessage : String {
        switch self.biometricType {
        case .TouchID: return "Turning off 'Remember Me' will disable Touch ID.".localize
        case .FaceID: return "Turning off 'Remember Me' will disable Face ID.".localize
        default: return self.biometricsFallbackMessage
        }
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
    var biometricsFailedMessage : String { return "There was a problem verifying your identity.".localize }
    var biometricsLoginMessage : String {
        switch biometricType {
        case .TouchID: return "Logging in with Touch ID".localize
        case .FaceID: return "Logging in with Face ID".localize
        default: return self.biometricsFallbackMessage
        }
    }
    
    var biometricsFallbackMessage : String {
        switch biometricType {
        case .TouchID: return "Touch ID not authorized for use.".localize
        case .FaceID: return "Face ID not authorized for use.".localize
        default: return "Biometrics not authorized for use.".localize
        }
    }
    
    var biometricsUnavailableMessage : String {
        switch biometricType {
        case .TouchID: return "Touch ID is not available on this device.".localize
        case .FaceID: return "Face ID is not available on this device.".localize
        default: return self.biometricsFallbackMessage
        }
    }
}
