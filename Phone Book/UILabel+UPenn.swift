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
    
    func setBaseStyles() {
        self.textColor = UIColor.upennBlack
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
