//
//  ContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/14/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol AddToFavoritesDelegate {
    func addToExistingFavoritesGroup()
    func createNewFavoritesGroup()
}

protocol ToggleFavoritesDelegate {
    func addToFavorites(for indexPath: IndexPath)
    func removeFromFavorites(for indexPath: IndexPath)
}

class ContactViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: ContactNameLabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: ContactDepartmentLabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var contact: Contact!
    var favoritesDelegate: ToggleFavoritesDelegate?
    var sectionIndex: IndexPath! // Includes Cells
    
    @IBAction func pressedFavoritesButton(_ sender: UIButton) {
        if self.contact.isFavorited {
            //            self.favoritesDelegate?.removeFromFavorites() TODO: Un-comment once full flow created
            FavoritesService.removeFromFavorites(self.contact, completion: { (success) in
                self.contact.isFavorited = false
                self.toggleFavoritesButton(isFavorited: self.contact.isFavorited)
                // TODO: Fire protocol?
            })
        } else {
            //            self.favoritesDelegate?.addToFavorites() TODO: Un-comment once full flow created
            // TODO: Fire delegate to show Alert, and pass -addToFaves method
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
        // TODO: Set
    }
    
    // TODO: Should be handled by FavoritesVC to reduce complexity
    func toggleFavoritesButton(isFavorited: Bool) {
        if isFavorited {
            self.favoritesButton.setTitle("UnFavorite", for: .normal)
            self.favoritesButton.setTitleColor(UIColor.upennCTAGreen, for: .normal)
        } else {
            self.favoritesButton.setTitle("Favorite", for: .normal)
            self.favoritesButton.setTitleColor(UIColor.upennMediumBlue, for: .normal)
        }
    }
}

private extension ContactViewCell {
    
    func setStyles() {
        self.jobTitleLabel.textColor = UIColor.darkGray
    }
}
