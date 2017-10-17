//
//  ContactDetailsViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class ContactDetailsViewController : UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var addressLabel1: UILabel!
    @IBOutlet weak var addressLabel2: UILabel!
    @IBOutlet weak var primaryPhoneLabel: UILabel!
    @IBOutlet weak var cellPhoneLabel: UILabel!
    
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _contact = self.contact else { return }
        
        self.decorateView(with: _contact)
    }
}

private extension ContactDetailsViewController {
    
    func decorateView(with contact: Contact) {
        self.nameLabel.text = contact.fullName
        self.jobTitleLabel.text = contact.jobTitle
        self.departmentLabel.text = contact.department
        self.addressLabel1.text = contact.primaryAddressLine1
        self.addressLabel2.text = contact.primaryAddressLine2
        self.primaryPhoneLabel.text = contact.displayPrimaryTelephone
        self.cellPhoneLabel.text = contact.displayCellPhone
    }
}
