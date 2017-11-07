//
//  ContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/14/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol ContactFavoritingDelegate {
    func addToFavorites(for indexPath: IndexPath)
    func removeFromFavorites(for indexPath: IndexPath)
}
protocol ToggleFavoritesDelegate {
    func toggleFavoritesState(_ favorited: Bool)
}

class ContactViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: ContactNameLabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: ContactDepartmentLabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var contact: Contact!
    var favoritesDelegate: ContactFavoritingDelegate?
    var sectionIndex: IndexPath! // Includes Cells
    
    @IBAction func pressedFavoritesButton(_ sender: UIButton) {
        if self.contact.isFavorited {
            self.favoritesDelegate?.removeFromFavorites(for: self.sectionIndex)
        } else {
            self.favoritesDelegate?.addToFavorites(for: self.sectionIndex)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setStyles()
    }
    
    func configure(with contact: Contact, delegate: ContactFavoritingDelegate, sectionIndex: IndexPath) {
        self.contact = contact
        self.nameLabel.text = contact.fullName
        self.jobTitleLabel.text = contact.jobTitle
        let strippedText = contact.department.components(separatedBy: ", Department of")
        if let text = strippedText.first, text.isEmpty == false {
            self.departmentLabel.text = String(describing: text)
        } else {
            self.departmentLabel.text = contact.department
        }
        self.favoritesDelegate = delegate
        self.sectionIndex = sectionIndex
        self.toggleFavoritesButton(isFavorited: self.contact.isFavorited)
    }
    
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

extension ContactViewCell : ToggleFavoritesDelegate {
    func toggleFavoritesState(_ favorited: Bool) {
        self.toggleFavoritesButton(isFavorited: favorited)
    }
}

private extension ContactViewCell {
    
    func setStyles() {
        self.jobTitleLabel.textColor = UIColor.darkGray
    }
}
