//
//  FavoritesContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/25/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol ContactServicable {
    func cannotEmailError()
    func cannotTextError()
}
class ContactService {
    
    let messagingService = MessagingService()
    let emailService = EmailService()
    var delegateViewController: UIViewController
    var contact: Contact!
    var contactDelegate: ContactServicable?
    var canEmail : Bool { return self.emailService.canSendMail }
    
    var canText : Bool { return self.messagingService.canSendText }
    
    init(viewController: UIViewController, contact: Contact) {
        self.delegateViewController = viewController
        self.contact = contact
        self.contactDelegate = viewController as? ContactServicable
    }
    
    @objc func callPhone() {
        if let phone = self.contact?.primaryTelephone, phone.isEmpty == false {
            self.callNumber(phoneNumber: phone)
        }
    }
    
    @objc func callCell() {
        if let cell = self.contact?.cellphone, cell.isEmpty == false {
            self.callNumber(phoneNumber: cell)
        }
    }
    
    @objc func sendEmail() {
        if let email = self.contact?.emailAddress, email.isEmpty == false {
            self.emailContact(emailAddress: email)
        }
    }
    
    @objc func sendText() {
        if let cell = self.contact?.cellphone, cell.isEmpty == false {
            self.textNumber(phoneNumber: cell)
        }
    }
    
    private func callNumber(phoneNumber: String) {
        if let url = URL(string: "telprompt:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func textNumber(phoneNumber: String) {
        let recipients = [phoneNumber]
        if canText {
            let messageComposeVC = messagingService.configuredMessageComposeViewController(textMessageRecipients: recipients)
            self.delegateViewController.present(messageComposeVC, animated: true, completion: nil)
        } else {
            self.contactDelegate?.cannotTextError()
        }
    }
    
    private func emailContact(emailAddress: String) {
        let recipients = [emailAddress]
        if canEmail {
            let emailComposeVC = emailService.configuredMailComposeViewController(mailRecipients: recipients)
            self.delegateViewController.present(emailComposeVC, animated: true, completion: nil)
        } else {
            self.contactDelegate?.cannotEmailError()
        }
    }
}

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
        self.jobTitleLabel.text = favContact.jobTitle
        self.departmentLabel.text = favContact.department
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
