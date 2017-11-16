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
        textLabel?.text = "Auto-Login"
        autoLoginSwitch.onTintColor = UIColor.upennMediumBlue
        self.autoLoginSwitch.setOn(self.shouldAutoLogin, animated: false)
        self.autoLoginSwitch.isSelected = self.shouldAutoLogin
        print("Switch State Launch:", self.autoLoginSwitch.isSelected)
    }
    
    @IBAction func toggledAutoLoginSwitch(_ sender: UISwitch) {
        AuthenticationService.toggleShouldAutoLogin(!self.autoLoginSwitch.isSelected)
        print("Switch State Toggle:", self.autoLoginSwitch.isSelected)
    }
}
