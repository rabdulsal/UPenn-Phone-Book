//
//  LogoutCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/9/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

class LogoutCell : UITableViewCell {
    
    @IBOutlet weak var logoutLabel: UPennLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure() {
        self.logoutLabel.textColor = UIColor.upennWarningRed
    }
}
