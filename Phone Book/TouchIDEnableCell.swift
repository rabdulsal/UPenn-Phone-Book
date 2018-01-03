//
//  TouchIDEnableCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 12/27/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol TouchIDToggleDelegate {
    func toggledTouchID(_ enabled: Bool)
}

class TouchIDEnableCell : UITableViewCell {
    
    @IBOutlet weak var touchIDSwitch: UISwitch!
    
    var touchIDDelegate: TouchIDToggleDelegate?
    
    @IBAction func toggledTouchID(_ sender: UISwitch) {
        self.touchIDDelegate?.toggledTouchID(!self.touchIDSwitch.isSelected)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.touchIDSwitch.onTintColor = UIColor.upennMediumBlue
    }
    
    func configure(with delegate: TouchIDToggleDelegate, touchIDAvailable: Bool, touchIDEnabled: Bool ) {
        let touchIDAvailableEnabled   = touchIDAvailable && touchIDEnabled
        self.touchIDDelegate          = delegate
        self.touchIDSwitch.isEnabled  = touchIDAvailable
        self.touchIDSwitch.isSelected = touchIDAvailableEnabled
        self.touchIDSwitch.setOn(touchIDAvailableEnabled, animated: false)
    }
}
