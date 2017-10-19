//
//  UIButton+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/19/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class PrimaryCTAButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    override var isEnabled: Bool {
        didSet {
            isEnabled ? setEnabledStyle() : setDisabledStyle()
        }
    }
    
    func setBaseStyles() {
        setEnabledStyle()
    }
    
    func setEnabledStyle() {
        titleLabel?.textColor = UIColor.white
        backgroundColor = UIColor.upennMediumBlue
    }
    
    func setDisabledStyle() {
        titleLabel?.textColor = UIColor.darkGray
        backgroundColor = UIColor.lightGray
    }
}
