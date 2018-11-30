//
//  ContactIconView.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/29/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol ContactIconViewDelegate {
    func selectedContactType(_ iconType: ContactIconView.IconType)
}

class ContactIconView : NibView {
    
    enum IconType : String {
        case Office
        case Mobile
        case Text
        case Email
        case Copy
    }
    
    @IBOutlet weak var contactButton: ContactIconButton!
    @IBOutlet weak var contactTypeLabel: UPennLabel!
    var favoriteContact: FavoritesContact!
    var iconType: IconType = .Email
    var delegate: ContactIconViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupGestureRecognizer()
    }
    
    @IBAction func pressedContactButton(_ sender: UIButton) {
        self.delegate?.selectedContactType(self.iconType)
    }
    
    func configure(
        with delegate: ContactIconViewDelegate,
        iconType: IconType,
        favContact: FavoritesContact) {
        self.favoriteContact = favContact
        self.delegate = delegate
        self.configureIconType(type: iconType)
    }
}

private extension ContactIconView {
    func configureIconType(type: IconType) {
        self.iconType = type
        switch type {
        case .Mobile:
            self.contactButton.setImage(#imageLiteral(resourceName: "phone"), for: .normal)
            self.contactTypeLabel.text = "Mobile"
            if let textNumber = self.favoriteContact.displayCellPhone, !textNumber.isEmpty {
                self.enable()
            } else {
                self.disable()
            }
        case .Email:
            self.contactButton.setImage(#imageLiteral(resourceName: "email"), for: .normal)
            self.contactTypeLabel.text = "Email"
            if let emailAddress = self.favoriteContact.emailAddress, !emailAddress.isEmpty {
                self.enable()
            } else {
                self.disable()
            }
        case .Text:
            self.contactButton.setImage(#imageLiteral(resourceName: "chat_bubbles"), for: .normal)
            self.contactTypeLabel.text = "Text"
            if let mobilePhone = self.favoriteContact.displayCellPhone, !mobilePhone.isEmpty {
                self.enable()
            } else {
                self.disable()
            }
        case .Office:
            self.contactButton.setImage(#imageLiteral(resourceName: "phone"), for: .normal)
            self.contactTypeLabel.text = "Office"
            if let officePhone = self.favoriteContact.displayPrimaryTelephone, !officePhone.isEmpty {
                self.enable()
            } else {
                self.disable()
            }
        case .Copy:
            self.contactButton.setImage(#imageLiteral(resourceName: "copy_152"), for: .normal)
            self.contactTypeLabel.text = "Copy Email"
            if let email = self.favoriteContact.emailAddress, !email.isEmpty {
                self.enable()
            } else {
                self.disable()
            }
        }
    }
    
    func enable() {
        self.contactButton.isHidden = false
        self.contactTypeLabel.isHidden = false
    }
    
    func disable() {
        self.contactButton.isHidden = true
        self.contactTypeLabel.isHidden = true
    }
    
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.pressedContactButton(_:)))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        contactTypeLabel.isUserInteractionEnabled = true
        contactTypeLabel.addGestureRecognizer(tap)
    }
}

extension ContactIconView : UIGestureRecognizerDelegate { }
