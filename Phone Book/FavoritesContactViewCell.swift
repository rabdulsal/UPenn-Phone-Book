//
//  FavoritesContactViewCell.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/25/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class ContactService {
    
    let messagingService = MessagingService()
    let emailService = EmailService()
    var delegateViewController: UIViewController
    var contact: Contact!
    
    var canEmail : Bool { return self.emailService.canSendMail }
    
    var canText : Bool { return self.messagingService.canSendText }
    
    init(viewController: UIViewController, contact: Contact) {
        self.delegateViewController = viewController
        self.contact = contact
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
    
    func callNumber(phoneNumber: String) {
        if let url = URL(string: "telprompt:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func textNumber(phoneNumber: String) {
        let recipients = [phoneNumber]
        let messageComposeVC = messagingService.configuredMessageComposeViewController(textMessageRecipients: recipients)
        self.delegateViewController.present(messageComposeVC, animated: true, completion: nil)
    }
    
    func emailContact(emailAddress: String) {
        let recipients = [emailAddress]
        let emailComposeVC = emailService.configuredMailComposeViewController(mailRecipients: recipients)
        self.delegateViewController.present(emailComposeVC, animated: true, completion: nil)
    }
    
    
}

class FavoritesContactViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: ContactNameLabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: ContactDepartmentLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(with favContact: FavoritesContact) {
        self.nameLabel.text = favContact.fullName
        self.jobTitleLabel.text = favContact.jobTitle
        self.departmentLabel.text = favContact.department
        
        // TODO: Set up GestureRecognizers
    }
}
