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
    
    @IBOutlet weak var nameLabel: ContactNameLabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: ContactDepartmentLabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var contact: Contact!
    var favoritesDelegate: FavoritesDelegate?
    
    @IBAction func pressedFavoritesButton(_ sender: UIButton) {
        if self.contact.isFavorited {
            FavoritesService.removeFromFavorites(self.contact, completion: { (success) in
                self.contact.isFavorited = false
                self.toggleFavoritesButton(isFavorited: self.contact.isFavorited)
                // TODO: Fire protocol?
            })
        } else {
            FavoritesService.addToFavorites(self.contact, completion: { (favContact: FavoritesContact) -> Void in
                self.contact.isFavorited = true
                self.toggleFavoritesButton(isFavorited: self.contact.isFavorited)
                // TODO: Fire protocol
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setStyles()
    }
    
    func configure(with contact: Contact) {
        self.contact = contact
        self.nameLabel.text = contact.fullName
        self.jobTitleLabel.text = contact.jobTitle
        self.departmentLabel.text = contact.department
        self.toggleFavoritesButton(isFavorited: self.contact.isFavorited)
    }
}

private extension ContactViewCell {
    
    func toggleFavoritesButton(isFavorited: Bool) {
        if isFavorited {
            self.favoritesButton.setTitle("UnFavorite", for: .normal)
            self.favoritesButton.setTitleColor(UIColor.upennCTAGreen, for: .normal)
        } else {
            self.favoritesButton.setTitle("Favorite", for: .normal)
            self.favoritesButton.setTitleColor(UIColor.upennMediumBlue, for: .normal)
        }
    }
    
    func setStyles() {
        self.jobTitleLabel.textColor = UIColor.darkGray
    }
}
