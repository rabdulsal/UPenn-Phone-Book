//
//  AccountSettingsCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 11/16/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class AccountSettingsCell : UITableViewCell {
    
    @IBOutlet weak var autoLoginSwitch : UISwitch!
    
    private var shouldAutoLogin : Bool { return AuthenticationService.shouldAutoLogin }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        autoLoginSwitch.onTintColor = UIColor.upennMediumBlue
        if AuthenticationService.shouldAutoFill {
            textLabel?.text = "Auto-Login"
            self.autoLoginSwitch.setOn(self.shouldAutoLogin, animated: false)
            self.autoLoginSwitch.isSelected = self.shouldAutoLogin
        } else {
            self.autoLoginSwitch.setOn(false, animated: false)
            self.autoLoginSwitch.isEnabled = false
            textLabel?.text = "Auto-Login (Disabled)"
            textLabel?.textColor = UIColor.upennCTALightBlue
        }
    }
    
    @IBAction func toggledAutoLoginSwitch(_ sender: UISwitch) {
        AuthenticationService.toggleShouldAutoLogin(!self.autoLoginSwitch.isSelected)
    }
}
