//
//  ViewController.swift
//  Phone Book
//
//  Created by Admin on 10/11/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: PrimaryCTAButton!
    @IBOutlet weak var autoFillButton: PrimaryCTAButtonText!
    @IBOutlet weak var titleLabel: BannerLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rememberMeLabel: ContactDepartmentLabel!
    @IBOutlet weak var goToFavsButton: OutlineCTAButton!
    
    fileprivate var validationService: ValidationService!
    fileprivate var keyboardService: KeyboardService!
    fileprivate var biometricsService: BiometricsAuthService!
    fileprivate var appDelegate : AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    lazy var touchIDAlertController : UIAlertController = {
        let alertController = UIAlertController(
            title: self.biometricsService.touchIDOptInTitle,
            message: self.biometricsService.touchIDOptInMessage,
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.biometricsService.touchIDDeclined, style: .cancel, handler: {
            alert -> Void in
            self.dismiss()
        })
        let useTouchIDAction = UIAlertAction(title: self.biometricsService.touchIDConfirmed, style: .default, handler: {
            alert -> Void in
            // Turn on Biometrics Settings
            self.turnOnBiometricAuthSettings()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(useTouchIDAction)
        return alertController
    }()
    
    lazy var rememberMeAlertController : UIAlertController = {
        let alertController = UIAlertController(
            title: self.biometricsService.biometricOptOutMessage,
            message: "",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil)
        let disableRememberMe = UIAlertAction(title: "OK".localize, style: .default, handler: {
            alert -> Void in
            self.biometricsService.toggleBiometrics(false)
            self.toggleRememberMe()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(disableRememberMe)
        return alertController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.goToFavsButton.isHidden = FavoritesService.favoritesGroupsCount < 1
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewDidAppear()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.validationService.resetTextFields()
        self.keyboardService.endObservingKeyboard()
    }
    
    override func setup() {
        super.setup()
        self.appDelegate?.setLoginDelegate(loginDelegate: self)
        self.biometricsService = BiometricsAuthService(biometricsDelegate: self)
        
        // Set up textFields
        self.emailField.delegate = self
        self.emailField.placeholder = "username".localize
        self.emailField.autocorrectionType = .no
        self.emailField.returnKeyType = .next
        self.emailField.addCancelButton()
        self.passwordField.autocorrectionType = .no
        self.passwordField.placeholder = "password".localize
        self.passwordField.delegate = self
        self.passwordField.returnKeyType = .done
        self.passwordField.isSecureTextEntry = true
        self.passwordField.addCancelButton()
        self.validationService = ValidationService(textFields: [ self.emailField, self.passwordField ])
        
        // Set up Buttons
        self.autoFillButton.adjustsImageWhenHighlighted = false
        self.autoFillButton.setImage(#imageLiteral(resourceName: "checked"), for: .selected)
        self.autoFillButton.setImage(#imageLiteral(resourceName: "un_checked"), for: .normal)
        
        // Set up Touch Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.toggleLoginAutoFill))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        self.rememberMeLabel.isUserInteractionEnabled = true
        self.rememberMeLabel.addGestureRecognizer(tap)
        self.rememberMeLabel.textColor = UIColor.upennDarkBlue
        
        // Load Favorites
        FavoritesService.loadFavoritesData()
        
        // Keyboard Service
        self.keyboardService = KeyboardService(self.scrollView)
    }
    
    @IBAction func pressedClose(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func pressedLogin(_ sender: Any) {
        self.login()
    }
    
    @IBAction func pressedAutoFillButton(_ sender: UIButton) {
        self.toggleLoginAutoFill()
    }
    
    @IBAction func pressedGoToFavorites(_ sender: Any) {
        self.dismiss()
        self.appDelegate?.goToSection(.Favorites)
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.advanceTextfields(textfield: textField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
}

// MARK: - LoginService Delegate

extension LoginViewController : LoginServiceDelegate {
    
    func didSuccessfullyLoginUser() {
        SVProgressHUD.dismiss()
        
        /*
         * 1. Trigger Logout timer
         * 2. Check for 1st Launch & conditionally launch Biometrics opt-in
        */
        self.appDelegate?.resetLogoutTimer()
        self.appDelegate?.checkFirstLogin(completion: { (isFirstLogin) in
            if let isFirstLogin = self.appDelegate?.isFirstLogin, isFirstLogin {
                self.appDelegate?.setFirstLogin()
                // If Biometrics available, 
                if self.biometricsService.biometricsAvailable {
                    switch self.biometricsService.biometricType {
                    case .TouchID:
                        self.present(self.touchIDAlertController, animated: true, completion: nil)
                    default:
                        self.biometricsService.utilizeBiometricAuthentication(isfirstLogin: isFirstLogin)
                    }
                    return
                }
            }
            self.dismiss()
            
            // Analytics
            AnalyticsService.trackLoginEvent()
        })
    }
    
    func didReturnAutoFillCredentials(username: String, password: String) {
        self.emailField.text = username
    }
    
    func didFailToLoginUser(errorStr: String) {
        SVProgressHUD.showError(withStatus: errorStr)
    }
}

// MARK: - BiometricsDelegate

extension LoginViewController : BiometricsDelegate {
    func biometricsSuccessfullyAuthenticated(isFirstLogin: Bool) {
        // Check if isFirstLogin - indicates user has opted-in to use biometrics, so must trigger settings updates
        if isFirstLogin {
            self.turnOnBiometricAuthSettings()
            return
        }
        SVProgressHUD.show(withStatus: "Logging in.....")
        self.appDelegate?.attemptSilentLogin()
    }
    
    func biometricsDidError(with message: String?, isFirstLogin: Bool) {
        // Check if isFirstLogin - indicates user has canceled opt-in to biometrics, so complete login and push to ContactsListVC
        if isFirstLogin {
            self.dismiss()
            return
        }
        guard let m = message else { return }
        SVProgressHUD.showError(withStatus: m)
    }
}

// MARK: - Private

private extension LoginViewController {
    
    func verifyFields() {
        self.loginButton.isEnabled = validationService.loginFieldsAreValid
    }
    
    func viewDidAppear() {
        self.appDelegate?.authenticationAutoFillCheck()
        verifyFields()
        self.attemptBiometricsPresentation()
        self.autoFillButton.isSelected = self.appDelegate?.shouldAutoFill ?? false
        self.keyboardService.beginObservingKeyboard()
    }
    
    func login() {
        SVProgressHUD.show()
        self.appDelegate?.makeLoginRequest(email: self.emailField.text!, password: self.passwordField.text!)
    }
    
    @objc func toggleLoginAutoFill() {
        if autoFillButton.isSelected && self.biometricsService.biometricsEnabled {
            self.present(self.rememberMeAlertController, animated: true, completion: nil)
            return
        }
        self.toggleRememberMe()
    }
    
    @objc func textFieldDidChange(_ sender: Any) {
        verifyFields()
    }
    
    func toggleRememberMe(_ enabled: Bool = false) {
        if enabled {
            self.autoFillButton.isSelected = enabled
            self.appDelegate?.toggleShouldAutoFill(enabled)
            return
        }
        self.autoFillButton.isSelected = !self.autoFillButton.isSelected
        self.appDelegate?.toggleShouldAutoFill(self.autoFillButton.isSelected)
    }
    
    func advanceTextfields(textfield: UITextField) {
        let nextTag: NSInteger = textfield.tag + 1
        if let nextResponder: UIResponder = textfield.superview!.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
            self.login()
        }
    }
    
    func attemptBiometricsPresentation() {
        if let shouldAutoFill = self.appDelegate?.shouldAutoFill, shouldAutoFill {
            self.biometricsService.attemptBiometricsAuthentication()
        }
    }
    
    func turnOnBiometricAuthSettings() {
        /*
         * 1. Toggle biometrics enabled On
         * 2. Toggle 'Remember Me' On
         * 3. Cache login credentials
         * 4. Close LoginVC
         */
        self.biometricsService.toggleBiometrics(true)
        self.toggleRememberMe(true)
        self.appDelegate?.cacheLoginCredentials(username: emailField.text!, password: passwordField.text!)
        self.dismiss()
    }
}

extension LoginViewController : UIGestureRecognizerDelegate { }
