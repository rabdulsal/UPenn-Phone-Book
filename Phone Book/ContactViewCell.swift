//
//  ContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/14/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class ContactViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    
    override func awakeFromNib() {
        self.selectionStyle = .none
    }
    
    func configure(with contact: Contact) {
        self.nameLabel.text = contact.fullName
        self.jobTitleLabel.text = contact.jobTitle
        self.departmentLabel.text = contact.department
    }
}
