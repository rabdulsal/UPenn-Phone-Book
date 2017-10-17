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
    
    var loginService = LoginService()
    
    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.resetTextFields()
    }
    
    @IBAction func pressedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedLogin(_ sender: Any) {
        guard
            let emptyEmail = emailField.text?.isEmpty,
            let emptyPassword = passwordField.text?.isEmpty else {
                return
        }
        
        if !emptyEmail && !emptyPassword {
            self.email = emailField.text!
            self.password = passwordField.text!
            SVProgressHUD.show()
            // TODO: Must disable button and textFields
            self.loginService.makeLoginRequest(email: self.email, password: self.password, completion: { (success, error) in
                SVProgressHUD.dismiss()
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else if let e = error {
                    // Present Error in Alert
                    SVProgressHUD.showError(withStatus: e.localizedDescription)
                }
            })
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController : UITextFieldDelegate {
    
}

// MARK: - Private

private extension LoginViewController {
    
    func resetTextFields() {
        emailField.text = ""
        passwordField.text = ""
    }
}

