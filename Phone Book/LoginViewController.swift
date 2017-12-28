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
    
    var validationService: ValidationService!
    var passwordItems: [KeychainPasswordItem] = []
    var touchIDService: TouchIDAuthService!
    var appDelegate : AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    lazy var touchIDAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Use TouchID for login in the future?", message: "TouchID makes Login more convenient. These Settings can be updated in the Account section.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            alert -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        let useTouchIDAction = UIAlertAction(title: "Use TouchID", style: .default, handler: {
            alert -> Void in
            self.touchIDService.toggleTouchID(true)
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(useTouchIDAction)
        return alertController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.appDelegate?.authenticationAutoFillCheck()
        verifyFields()
        self.touchIDService.attemptTouchIDAuthentication()
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
        if let delegate = self.appDelegate {
            self.autoFillButton.isSelected = delegate.shouldAutoFill
        } else {
            self.autoFillButton.isSelected = false
        }
    }
    
    @IBAction func pressedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedLogin(_ sender: Any) {
        self.login()
    }
    
    @IBAction func pressedAutoFillButton(_ sender: UIButton) {
        self.autoFillButton.isSelected = !self.autoFillButton.isSelected
        self.appDelegate?.toggleShouldAutoFill(self.autoFillButton.isSelected)
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
        self.appDelegate?.checkFirstLogin(completion: { (isFirstLogin) in
            if isFirstLogin {
                self.present(self.touchIDAlertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
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
        self.appDelegate?.makeLoginRequest(email: self.emailField.text!, password: self.passwordField.text!)
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
