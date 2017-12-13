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
    @IBOutlet weak var autoLoginButton: PrimaryCTAButtonText! // TODO: Eventually change to Auto-fill
    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var titleLabel: BannerLabel!
    
    var loginService: LoginService!
    var validationService: ValidationService!
    var passwordItems: [KeychainPasswordItem] = []
    var touchIDSerivce: TouchIDAuthService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loginService.authenticationAutoFillCheck()
        verifyFields()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.validationService.resetTextFields()
    }
    
    override func setup() {
        super.setup()
        self.loginService = LoginService(loginDelegate: self)
        self.touchIDSerivce = TouchIDAuthService(touchIDDelegate: self)
        
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
        self.autoLoginButton.adjustsImageWhenHighlighted = false
        self.autoLoginButton.setImage(UIImage.init(named: "checked"), for: .selected)
        self.autoLoginButton.setImage(UIImage.init(named: "un_checked"), for: .normal)
        self.autoLoginButton.isSelected = self.loginService.shouldAutoFill
        self.touchIDButton.isHidden = !touchIDSerivce.canEvaluatePolicy()
    }
    
    @IBAction func pressedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedLogin(_ sender: Any) {
        self.login()
    }
    
    @IBAction func pressedAutoLoginButton(_ sender: UIButton) {
        self.autoLoginButton.isSelected = !self.autoLoginButton.isSelected
        // TODO: Eventually change to Auto-fill & un-comment
        self.loginService.toggleShouldAutoFill(self.autoLoginButton.isSelected)
    }
    
    @IBAction func pressedTouchIDButton(_ sender: UIButton) {
        self.touchIDSerivce.authenticateUser()
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
        self.dismiss(animated: true, completion: nil)
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
        self.dismiss(animated: true, completion: nil)
    }
    
    func touchIDDidError(with message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
}

// MARK: - Private

private extension LoginViewController {
    
    func verifyFields() {
        self.loginButton.isEnabled = validationService.loginFieldsAreValid
    }
    
    func login() {
        SVProgressHUD.show()
        // TODO: Must disable button and textFields
        self.loginService.makeLoginRequest(email: self.emailField.text!, password: self.passwordField.text!)
    }
    
    @objc func textFieldDidChange(_ sender: Any) {
        verifyFields()
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
}

