//
//  BiometricsEnableCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 12/27/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol BiometricsToggleDelegate {
    func toggledBiometrics(_ enabled: Bool)
}

class BiometricsEnableCell : UITableViewCell {
    
    @IBOutlet weak var biometricsImage: UIImageView!
    @IBOutlet weak var biometricsToggleLabel: UPennLabel!
    @IBOutlet weak var biometricsSwitch: UISwitch!
    
    var biometricsDelegate: BiometricsToggleDelegate?
    
    @IBAction func toggledBiometrics(_ sender: UISwitch) {
        self.biometricsDelegate?.toggledBiometrics(!self.biometricsSwitch.isSelected)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.biometricsSwitch.onTintColor = UIColor.upennMediumBlue
    }
    
    func configure(with delegate: BiometricsToggleDelegate, biometricsService: BiometricsAuthService ) {
        self.biometricsToggleLabel.text  = biometricsService.toggleTitleText
        self.biometricsDelegate          = delegate
        self.biometricsSwitch.isEnabled  = biometricsService.biometricsAvailable
        self.biometricsSwitch.isSelected = biometricsService.biometricsEnabled
        self.biometricsImage.image       = biometricsService.biometricToggleImage
        self.biometricsSwitch.setOn(biometricsService.biometricsEnabled, animated: false)
    }
}
