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
    var email = ""
    var password = ""
    var passwordItems: [KeychainPasswordItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginService = LoginService(loginDelegate: self)
        self.validationService = ValidationService(textFields: [ self.emailField, self.passwordField ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loginService.authenticationAutoFillCheck()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.validationService.resetTextFields()
    }
    
    @IBAction func pressedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedLogin(_ sender: Any) {
        
        if validationService.loginFieldsAreValid {
            self.email = emailField.text!
            self.password = passwordField.text!
            SVProgressHUD.show()
            // TODO: Must disable button and textFields
            self.loginService.makeLoginRequest(email: self.email, password: self.password)
        } else {
            SVProgressHUD.showError(withStatus: "Login Fields cannot be empty.")
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController : UITextFieldDelegate {
    
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
    // TODO: Place private methods
}

