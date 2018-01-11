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
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = UIColor.upennMediumBlue
    }
    
    func setDisabledStyle() {
        setTitleColor(UIColor.darkGray, for: .disabled)
        backgroundColor = UIColor.lightGray
    }
}

class PrimaryCTAButtonText : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDeSelectedStyle()
        backgroundColor = UIColor.clear
    }
    
    override var isSelected: Bool {
        didSet {
            isSelected ? setSelectedStyle() : setDeSelectedStyle()
        }
    }
    
    func setSelectedStyle() {
        setTitleColor(UIColor.upennWarningRed, for: .selected)
    }
    
    func setDeSelectedStyle() {
        setTitleColor(UIColor.upennMediumBlue, for: .normal)
    }
}

class ContactIconButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class OutlineCTAButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    func setBaseStyles() {
        setTitleColor(UIColor.upennMediumBlue, for: .normal)
        backgroundColor = UIColor.white
        layer.borderWidth = 2
        layer.borderColor = UIColor.upennMediumBlue.cgColor
    }
}
