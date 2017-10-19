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
    
    var loginService: LoginService!
    var validationService: ValidationService!
    var passwordItems: [KeychainPasswordItem] = []
    
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
    
    @IBAction func pressedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedLogin(_ sender: Any) {
        self.login()
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
        self.passwordField.text = password
    }
    
    func didFailToLoginUser(errorStr: String) {
        SVProgressHUD.showError(withStatus: errorStr)
    }
}

// MARK: - Private

private extension LoginViewController {
    func setup() {
        self.loginService = LoginService(loginDelegate: self)
        
        // Set up textFields
        self.emailField.delegate = self
        self.passwordField.delegate = self        
        self.passwordField.returnKeyType = .done
        self.passwordField.isSecureTextEntry = true
        self.validationService = ValidationService(textFields: [ self.emailField, self.passwordField ])
    }
    
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

