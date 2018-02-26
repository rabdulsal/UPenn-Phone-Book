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
    fileprivate var touchIDService: TouchIDAuthService!
    fileprivate var appDelegate : AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    lazy var touchIDAlertController : UIAlertController = {
        let alertController = UIAlertController(
            title: "Use TouchID for login in the future?".localize,
            message: "TouchID makes Login more convenient. These Settings can be updated in the Account section.".localize,
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No Thanks".localize, style: .cancel, handler: {
            alert -> Void in
            self.dismiss()
        })
        let useTouchIDAction = UIAlertAction(title: "Use TouchID".localize, style: .default, handler: {
            alert -> Void in
            /*
             * 1. Toggle TouchID 'on'
             * 2. Force turn 'Remember Me' on for caching login credentials
            */
            self.touchIDService.toggleTouchID(true)
            self.autoFillButton.isSelected = true
            self.appDelegate?.toggleShouldAutoFill(true)
            self.dismiss()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(useTouchIDAction)
        return alertController
    }()
    
    lazy var rememberMeAlertController : UIAlertController = {
        let alertController = UIAlertController(
            title: "Turning off 'Remember Me' will disable TouchID.".localize,
            message: "",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil)
        let disableRememberMe = UIAlertAction(title: "OK".localize, style: .default, handler: {
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
        self.touchIDService = TouchIDAuthService(touchIDDelegate: self)
        
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
        self.autoFillButton.setImage(UIImage.init(named: "checked"), for: .selected)
        self.autoFillButton.setImage(UIImage.init(named: "un_checked"), for: .normal)
        
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
        self.attemptTouchIDPresentation()
        if let delegate = self.appDelegate {
            self.autoFillButton.isSelected = delegate.shouldAutoFill
        } else {
            self.autoFillButton.isSelected = false
        }
        self.keyboardService.beginObservingKeyboard()
    }
    
    func login() {
        SVProgressHUD.show()
        self.appDelegate?.makeLoginRequest(email: self.emailField.text!, password: self.passwordField.text!)
    }
    
    @objc func toggleLoginAutoFill() {
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

extension LoginViewController : UIGestureRecognizerDelegate { }
