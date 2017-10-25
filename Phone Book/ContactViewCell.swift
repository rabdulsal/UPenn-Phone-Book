//
//  ContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/14/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol FavoritesDelegate {
    func favoritedContact(_ contact: Contact)
}

class ContactViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var contact: Contact!
    var favoritesDelegate: FavoritesDelegate?
    
    @IBAction func pressedFavoritesButton(_ sender: UIButton) {
        FavoritesService.saveContact(with: self.contact, completion: { (favContact: FavoritesContact) -> Void in
            // TODO: Update isFavorited on self.contact and fire protocol
                self.toggleFavoritesButton(isFavorited: true)
            })
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(with contact: Contact) {
        self.contact = contact
        self.nameLabel.text = contact.fullName
        self.jobTitleLabel.text = contact.jobTitle
        self.departmentLabel.text = contact.department
        self.toggleFavoritesButton(isFavorited: false)
    }
}

private extension ContactViewCell {
    
    func toggleFavoritesButton(isFavorited: Bool) {
        if isFavorited {
            self.favoritesButton.setTitleColor(UIColor.upennCTAGreen, for: .normal)
        } else {
            self.favoritesButton.setTitleColor(UIColor.upennMediumBlue, for: .normal)
        }
    }
}
