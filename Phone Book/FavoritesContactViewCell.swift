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
