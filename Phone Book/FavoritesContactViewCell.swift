//
//  FavoritesContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/25/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class FavoritesContactViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: ContactNameLabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: ContactDepartmentLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(with favContact: FavoritesContact) {
        self.nameLabel.text = favContact.fullName
        self.jobTitleLabel.text = favContact.jobTitle
        self.departmentLabel.text = favContact.department
    }
}
