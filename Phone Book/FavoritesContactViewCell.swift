//
//  FavoritesContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/25/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol FavoritesContactDelegate {
    func pressedCallPhoneButton(for contact: FavoritesContact)
    func pressedCallCellButton(for contact: FavoritesContact)
    func pressedTextButton(for contact: FavoritesContact)
    func pressedEmailButton(for contact: FavoritesContact)
}
class FavoritesContactViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: ContactNameLabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: ContactDepartmentLabel!
    @IBOutlet weak var callOfficeButton: ContactIconButton!
    @IBOutlet weak var callMobileButton: ContactIconButton!
    @IBOutlet weak var sendTextButton: ContactIconButton!
    @IBOutlet weak var sendEmailButton: ContactIconButton!
    
    var favoritesDelegate: FavoritesContactDelegate?
    var favoriteContact: FavoritesContact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(with favContact: FavoritesContact, and delegate: FavoritesContactDelegate) {
        self.favoriteContact = favContact
        self.favoritesDelegate = delegate
        self.nameLabel.text = favContact.fullName
        self.decorateView()
//        self.jobTitleLabel.text = favContact.jobTitle
//        self.departmentLabel.text = favContact.department
    }
    
    @IBAction func pressedCallPhoneButton(_ sender: Any) {
        self.favoritesDelegate?.pressedCallPhoneButton(for: self.favoriteContact)
    }
    
    @IBAction func pressedCallCellButton(_ sender: Any) {
        self.favoritesDelegate?.pressedCallCellButton(for: self.favoriteContact)
    }
    
    @IBAction func pressedTextButton(_ sender: Any) {
        self.favoritesDelegate?.pressedTextButton(for: self.favoriteContact)
    }
    
    @IBAction func pressedEmailButton(_ sender: Any) {
        self.favoritesDelegate?.pressedEmailButton(for: self.favoriteContact)
    }
}

extension FavoritesContactViewCell {
    func decorateView() {
        // TODO: Once Disabled button is added, update isHidden to isEnabled
        if let officePhone = self.favoriteContact.displayPrimaryTelephone {
            self.callOfficeButton.isHidden = officePhone.isEmpty
        } else {
            self.callOfficeButton.isHidden = true
        }
        
        if let mobilePhone = self.favoriteContact.displayCellPhone {
            self.callMobileButton.isHidden = mobilePhone.isEmpty
        } else {
            self.callMobileButton.isHidden = true
        }
        
        if let textNumber = self.favoriteContact.displayCellPhone {
            self.sendTextButton.isHidden = textNumber.isEmpty
        } else {
            self.sendTextButton.isHidden = true
        }
        
        if let emailAddress = self.favoriteContact.emailAddress {
            self.sendEmailButton.isHidden = emailAddress.isEmpty
        } else {
            self.sendEmailButton.isHidden = true
        }
    }
}
