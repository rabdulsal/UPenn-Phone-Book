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
    
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _contact = self.contact else { return }
        
        self.decorateView(with: _contact)
    }
}

private extension ContactDetailsViewController {
    
    func decorateView(with contact: Contact) {
        // Populate all labels with contact info
    }
}
