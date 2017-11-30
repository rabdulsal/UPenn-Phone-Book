//
//  ContactService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 11/30/17.
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
    
    init(viewController: UIViewController, contact: Contact, delegate: ContactServicable) {
        self.delegateViewController = viewController
        self.contact = contact
        self.contactDelegate = delegate
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
}

fileprivate extension ContactService {
    func callNumber(phoneNumber: String) {
        if let url = URL(string: "telprompt:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func textNumber(phoneNumber: String) {
        let recipients = [phoneNumber]
        if self.messagingService.canSendText {
            let messageComposeVC = messagingService.configuredMessageComposeViewController(textMessageRecipients: recipients)
            self.delegateViewController.present(messageComposeVC, animated: true, completion: nil)
        } else {
            self.contactDelegate?.cannotTextError()
        }
    }
    
    func emailContact(emailAddress: String) {
        let recipients = [emailAddress]
        if self.emailService.canSendMail {
            let emailComposeVC = emailService.configuredMailComposeViewController(mailRecipients: recipients)
            self.delegateViewController.present(emailComposeVC, animated: true, completion: nil)
        } else {
            self.contactDelegate?.cannotEmailError()
        }
    }
}
