//
//  UILabel+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/30/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class UPennLabel : UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    func setBaseStyles() {
        self.textColor = UIColor.upennBlack
        self.setFontHeight(size: 15.0)
    }
    
    func setFontHeight(size: CGFloat) {
        self.font = UIFont.init(name: "Helvetica Neue", size: size)
    }
}

class ContactNameLabel : UPennLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    override func setBaseStyles() {
        super.setBaseStyles()
        self.textColor = UIColor.upennDeepBlue
        self.setFontHeight(size: 20.0)
    }
}

class ContactDepartmentLabel : UPennLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    override func setBaseStyles() {
        super.setBaseStyles()
        self.textColor = UIColor.upennDarkBlue
        self.setFontHeight(size: 17.0)
    }
}

class ActionLabel : UPennLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    override func setBaseStyles() {
        super.setBaseStyles()
        self.textColor = UIColor.upennMediumBlue
    }
}

class NoDataInstructionsLabel : UPennLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    override func setBaseStyles() {
        super.setBaseStyles()
        self.textColor = UIColor.upennDarkBlue
        self.setFontHeight(size: 20.0)
    }
}

class BannerLabel : UPennLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBaseStyles()
    }
    
    override func setBaseStyles() {
        super.setBaseStyles()
        self.textColor = UIColor.upennDarkBlue
        self.setFontHeight(size: 25.0)
    }
}
