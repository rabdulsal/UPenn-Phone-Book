//
//  AutoLogoutCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 12/8/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class AutoLogoutCell : UITableViewCell {
    
    
    @IBOutlet weak var timeoutControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.timeoutControl.tintColor = UIColor.upennMediumBlue
        
        // Set font attributes to avoid segment label truncation
        let font = UIFont.init(name: "Helvetica Neue", size: 15.0)
        let attributes : [AnyHashable : Any] = [NSFontAttributeName:font!]
        self.timeoutControl.setTitleTextAttributes(attributes, for: .normal)
        self.timeoutControl.setTitleTextAttributes(attributes, for: .selected)
        
        self.timeoutControl.selectedSegmentIndex = TimerUIApplication.timeoutIndex
    }
    
    @IBAction func pressedTimeoutControl(_ sender: UISegmentedControl) {
        TimerUIApplication.updateTimeoutInterval(index: self.timeoutControl.selectedSegmentIndex)
    }
}
