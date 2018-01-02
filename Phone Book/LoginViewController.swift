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
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var validationService: ValidationService!
    var passwordItems: [KeychainPasswordItem] = []
    var touchIDService: TouchIDAuthService!
    var appDelegate : AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    lazy var touchIDAlertController : UIAlertController = {
        let alertController = UIAlertController(
            title: "Use TouchID for login in the future?",
            message: "TouchID makes Login more convenient. These Settings can be updated in the Account section.",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No Thanks", style: .cancel, handler: {
            alert -> Void in
            self.dismiss()
        })
        let useTouchIDAction = UIAlertAction(title: "Use TouchID", style: .default, handler: {
            alert -> Void in
            /*
             * 1. Toggle TouchID 'on'
             * 2. Toggle 'Remember Me' for caching login credentials
            */
            self.touchIDService.toggleTouchID(true)
            self.toggleLoginAutoFill()
            self.dismiss()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(useTouchIDAction)
        return alertController
    }()
    
    lazy var rememberMeAlertController : UIAlertController = {
        let alertController = UIAlertController(
            title: "Turning off 'Remember Me' will disable TouchID.",
            message: "",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let disableRememberMe = UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            self.touchIDService.toggleTouchID(false)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.validationService.resetTextFields()
    }
    
    override func setup() {
        super.setup()
        self.appDelegate?.setLoginDelegate(loginDelegate: self)
        self.touchIDService = TouchIDAuthService(touchIDDelegate: self)
        
        // Set up textFields
        self.emailField.delegate = self
        self.emailField.placeholder = "username"
        self.emailField.autocorrectionType = .no
        self.passwordField.autocorrectionType = .no
        self.passwordField.placeholder = "password"
        self.passwordField.delegate = self
        self.passwordField.returnKeyType = .done
        self.passwordField.isSecureTextEntry = true
        self.validationService = ValidationService(textFields: [ self.emailField, self.passwordField ])
        
        // Set up Buttons
        self.autoFillButton.adjustsImageWhenHighlighted = false
        self.autoFillButton.setImage(UIImage.init(named: "checked"), for: .selected)
        self.autoFillButton.setImage(UIImage.init(named: "un_checked"), for: .normal)
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
         * 2. Check for 1st Launch & conditionally launch TouchID opt-in
        */
        self.appDelegate?.resetLogoutTimer()
        self.appDelegate?.checkFirstLogin(completion: { (isFirstLogin) in
            if isFirstLogin {
                self.appDelegate?.setFirstLogin()
                if self.touchIDService.touchIDAvailable {
                    self.present(self.touchIDAlertController, animated: true, completion: nil)
                    return
                }
            }
            self.dismiss()
        })
    }
    
    func didReturnAutoFillCredentials(username: String, password: String) {
        self.emailField.text = username
    }
    
    func didFailToLoginUser(errorStr: String) {
        SVProgressHUD.showError(withStatus: errorStr)
    }
}

// MARK: - TouchIDService Delegate

extension LoginViewController : TouchIDDelegate {
    func touchIDSuccessfullyAuthenticated() {
        SVProgressHUD.show()
        self.appDelegate?.attemptSilentLogin()
    }
    
    func touchIDDidError(with message: String?) {
        if let m = message {
            SVProgressHUD.showError(withStatus: m)
        }
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
        self.attemptTouchIDPresentation()
        if let delegate = self.appDelegate {
            self.autoFillButton.isSelected = delegate.shouldAutoFill
        } else {
            self.autoFillButton.isSelected = false
        }
    }
    
    func login() {
        SVProgressHUD.show()
        self.appDelegate?.makeLoginRequest(email: self.emailField.text!, password: self.passwordField.text!)
    }
    
    func toggleLoginAutoFill() {
        if autoFillButton.isSelected && self.touchIDService.touchIDEnabled {
            self.present(self.rememberMeAlertController, animated: true, completion: nil)
            return
        }
        self.toggleRememberMe()
    }
    
    @objc func textFieldDidChange(_ sender: Any) {
        verifyFields()
    }
    
    func toggleRememberMe() {
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
    
    func attemptTouchIDPresentation() {
        if let shouldAutoFill = self.appDelegate?.shouldAutoFill, shouldAutoFill {
            self.touchIDService.attemptTouchIDAuthentication()
        }
    }
}
