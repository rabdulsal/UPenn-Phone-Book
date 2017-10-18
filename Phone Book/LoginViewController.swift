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
    @IBOutlet weak var loginButton: UIButton!
    
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
    
    func didFailToLoginUser(errorStr: String) {
        SVProgressHUD.showError(withStatus: errorStr)
    }
}

// MARK: - Private

private extension LoginViewController {
    
    // Enable/disable loginButton
    
    func loginUser() {
        SVProgressHUD.show()
        // TODO: MAY NOT NEED!
//        self.loginService.makeLoginRequest(email: self.email, password: self.password, completion: { (success, error) in
//            SVProgressHUD.dismiss()
//            if success {
//                self.dismiss(animated: true, completion: nil)
//            } else if let e = error {
//                // Present Error in Alert
//                SVProgressHUD.showError(withStatus: e.localizedDescription)
//            }
//        })
    }
}

