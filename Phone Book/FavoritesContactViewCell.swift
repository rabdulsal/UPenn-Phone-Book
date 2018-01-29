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
    @IBOutlet weak var officeView: ContactIconView!
    @IBOutlet weak var emailView: ContactIconView!
    @IBOutlet weak var mobileView: ContactIconView!
    @IBOutlet weak var textView: ContactIconView!
    @IBOutlet weak var callOfficeButton: ContactIconButton!
    @IBOutlet weak var callMobileButton: ContactIconButton!
    @IBOutlet weak var sendTextButton: ContactIconButton!
    @IBOutlet weak var sendEmailButton: ContactIconButton!
    
    var favoritesDelegate: FavoritesContactDelegate?
    var favoriteContact: FavoritesContact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
    }
    
    func configure(with favContact: FavoritesContact, and delegate: FavoritesContactDelegate) {
        self.favoriteContact = favContact
        self.favoritesDelegate = delegate
        self.nameLabel.text = favContact.fullName
        self.emailView.configure(with: self, iconType: ContactIconView.IconType.Email, favContact: self.favoriteContact)
        self.officeView.configure(with: self, iconType: ContactIconView.IconType.Office, favContact: self.favoriteContact)
        self.mobileView.configure(with: self, iconType: ContactIconView.IconType.Mobile, favContact: self.favoriteContact)
        self.textView.configure(with: self, iconType: ContactIconView.IconType.Text, favContact: self.favoriteContact)
        self.decorateView()
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

extension FavoritesContactViewCell : ContactIconViewDelegate {
    func didPressContactButton(for contact: FavoritesContact, iconType: ContactIconView.IconType) {
        print("Contact name: \(contact.firstName!) Type: \(iconType)")
    }
}

extension FavoritesContactViewCell {
    func decorateView() {
        if let officePhone = self.favoriteContact.displayPrimaryTelephone {
            self.callOfficeButton.isEnabled = !officePhone.isEmpty
        } else {
            self.callOfficeButton.isEnabled = false
        }
        
        if let mobilePhone = self.favoriteContact.displayCellPhone {
            self.callMobileButton.isEnabled = !mobilePhone.isEmpty
        } else {
            self.callMobileButton.isEnabled = false
        }
        
        if let textNumber = self.favoriteContact.displayCellPhone {
            self.sendTextButton.isEnabled = !textNumber.isEmpty
        } else {
            self.sendTextButton.isEnabled = false
        }
        
        if let emailAddress = self.favoriteContact.emailAddress {
            self.sendEmailButton.isEnabled = !emailAddress.isEmpty
        } else {
            self.sendEmailButton.isEnabled = false
        }
    }
}
