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
        self.emailView.configure(with: self, iconType: ContactIconView.IconType.Copy, favContact: self.favoriteContact)
        self.officeView.configure(with: self, iconType: ContactIconView.IconType.Office, favContact: self.favoriteContact)
        self.mobileView.configure(with: self, iconType: ContactIconView.IconType.Mobile, favContact: self.favoriteContact)
        self.textView.configure(with: self, iconType: ContactIconView.IconType.Text, favContact: self.favoriteContact)
    }
}

extension FavoritesContactViewCell : ContactIconViewDelegate {
    func selectedContactType(_ iconType: ContactIconView.IconType) {
        switch iconType {
        case .Email, .Copy:
            self.favoritesDelegate?.pressedEmailButton(for: self.favoriteContact)
        case .Mobile:
            self.favoritesDelegate?.pressedCallCellButton(for: self.favoriteContact)
        case .Office:
            self.favoritesDelegate?.pressedCallPhoneButton(for: self.favoriteContact)
        case .Text:
            self.favoritesDelegate?.pressedTextButton(for: self.favoriteContact)
        }
    }
}
