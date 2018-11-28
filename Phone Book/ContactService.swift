//
//  ContactService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 11/30/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

protocol RecipientsContactable {
    func contactRecipients(for recpients: [String], via messagingType: ContactService.MessagingType)
}

extension RecipientsContactable {
    func contactRecipients(for recipients: [String], via messagingType: ContactService.MessagingType) {
        var contactURL = ""
        let begin = 0
        let end = recipients.count - 1
        contactURL = messagingType == .Email ? "mailto:" : "sms:/open?addresses="
        
        for idx in begin...end {
            let recipient = recipients[idx]
            switch messagingType {
            case .Email:
                /*
                 * Loop through recipients and construct
                 * "mailto:recipient1@example.com?to=recipient2@example.com&to=recipient3@example.com"
                 * link
                 *
                 */
                if idx == begin {
                    contactURL += "\(recipient)?"
                    continue
                }
                if idx == end {
                    contactURL += "to=\(recipient)&from:rashad@gmail.com"
                    break
                }
                contactURL += "to=\(recipient)&"
            case .Text:
                /*
                 * Loop through recipients and construct
                 * "sms:/open?addresses=1-408-555-1212,1-408-555-2121,1-408-555-1221"
                 * link
                 */
                if idx == end {
                    contactURL += recipient
                    break
                }
                contactURL += "\(recipient),"
            }
        }
        if let url = URL(string: contactURL) {
            UIApplication.shared.open(url)
        }
    }
}

protocol MessageDelegate {
    func messageSent()
    func messageFailed(errorString: String)
}

protocol ContactServicable {
    func cannotEmailError(message: String)
    func cannotTextError(message: String)
    func cannotCallError(message: String)
}

class ContactService {
    enum MessagingType : String {
        case Email = "email"
        case Text = "text"
    }
    
    let textWarningMessage = "Text paging should NOT be used to communicate emergent or urgent clinical information as there is no guarantee that your page will be received. If you have urgent/emergent clinical information to communicate, please make verbal contact.".localize
    let emailWarningMessage = "You are now opening your iPhone's native Mail Application. Select your \"@pennmedicine.upenn.edu\" email address in the \"FROM:\" address line to ensure you are sending from your PennMedicine email address.".localize
    let cannotEmailError = "Sorry, this device's Account is not set up for email. Please go to Settings>Passwords & Accounts and ensure your 'Penn Medicine Email' is synced to your Mail App."
    let cannotTextError = "Sorry, this device's Account is not set up for text messaging."
    let cannotCallError = "Sorry, this device is not set up for making phone calls. ."
    let messagingService = MessagingService()
    let emailService = EmailService()
    var delegateViewController: UIViewController
    var contact: Contact?
    var favoriteContacts = [FavoritesContact]()
    var contactDelegate: ContactServicable?
    var emailMessageDelegate: MessageDelegate?
    fileprivate var textMessageRecipients = [String]()
    fileprivate var emailMessageRecipients = [String]()
    fileprivate var messagingType: MessagingType = .Email
    
    // Text Warning vars
    let textWarningKey = "textWarningKey"
    var textingVC: MFMessageComposeViewController?
    var textWarningFlag : Bool {
        guard let flagged = UserDefaults.standard.value(forKey: textWarningKey) as? Bool else { return false }
        return flagged
    }
    var canSendEmail: Bool {
        return self.emailService.canSendMail
    }
    var canSendText: Bool {
        return self.messagingService.canSendText
    }
    
    init(
        viewController: UIViewController,
        contact: Contact,
        emailMessageDelegate: MessageDelegate,
        contactDelegate: ContactServicable)
    {
        self.delegateViewController = viewController
        self.contact = contact
        self.contactDelegate = contactDelegate
        self.emailMessageDelegate = emailMessageDelegate
    }
    
    init(
        viewController: UIViewController,
        contacts: [FavoritesContact],
        emailMessageDelegate: MessageDelegate,
        contactDelegate: ContactServicable)
    {
        self.delegateViewController = viewController
        self.favoriteContacts = contacts
        self.contactDelegate = contactDelegate
        self.emailMessageDelegate = emailMessageDelegate
    }
    
    // Contact Individuals
    
    func callPhone() {
        if let phone = self.contact?.primaryTelephone, phone.isEmpty == false {
            self.callNumber(phoneNumber: phone)
        }
    }
    
    func callCell() {
        if let cell = self.contact?.cellphone, cell.isEmpty == false {
            self.callNumber(phoneNumber: cell)
        }
    }
    
    func sendEmail() {
        if let email = self.contact?.emailAddress, email.isEmpty == false {
            self.emailContact(emailAddress: [email])
        }
    }
    
    func sendText() {
        if let cell = self.contact?.cellphone, cell.isEmpty == false {
            self.textNumber(phoneNumber: [cell])
        }
    }
    
    // Contact Groups
    
    func textGroup() {
        self.textNumber(phoneNumber: self.makeContactList(from: self.favoriteContacts))
    }
    
    func emailGroup() {
        self.emailContact(emailAddress: self.makeContactList(from: self.favoriteContacts))
    }
    
    // Group Contact Management
    func reconcileContactSelectionState(contact: FavoritesContact) -> Bool {
        return self.favoriteContacts.filter { $0.fullName == contact.fullName }.count != 0
    }
    
    func addToContactGroup(_ contact: FavoritesContact, completion:(_ hasFavorites: Bool)->Void) {
        self.favoriteContacts.append(contact)
        completion(self.favoriteContacts.count>0)
    }
    
    func removeFromContactGroup(_ contact: FavoritesContact, completion:(_ hasFavorites: Bool)->Void) {
        guard let idx = self.favoriteContacts.index(of: contact) else { return }
        self.favoriteContacts.remove(at: idx)
        completion(self.favoriteContacts.count>0)
    }
}

extension ContactService : MessageDelegate {
    func messageSent() {
        self.emailMessageDelegate?.messageSent()
    }
    
    func messageFailed(errorString: String) {
        self.emailMessageDelegate?.messageFailed(errorString: errorString)
    }
}

fileprivate extension ContactService {
    
    var messageWarningAlert : UIAlertController {
        let messagingLauncherCallback: ([String], MessagingType) -> Void = self.messagingService.contactRecipients
        var message: String
        var recipients: [String]
        switch self.messagingType {
        case .Email:
            message = emailWarningMessage
            recipients = self.emailMessageRecipients
        case .Text:
            message = textWarningMessage
            recipients = self.textMessageRecipients
        }
        let alertController = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let okayAction = UIAlertAction(
            title: "OK".localize,
            style: .default,
            handler: {
                alert -> Void in
                // Show MessagingVC
                messagingLauncherCallback(recipients,self.messagingType)
        })
        // TODO: Uncomment to allow suppressing Text Warning in future
        //        let okayDontShowAction = UIAlertAction(
        //            title: "OK, don't show this again.".localize,
        //            style: .default,
        //            handler: {
        //                alert -> Void in
        //                /*
        //                 * 1. Update don't show bool
        //                 * 2. Show MessagingVC
        //                 */
        //                UserDefaults.standard.setValue(true, forKey: self.textWarningKey)
        //                self.delegateViewController.present(self.textingVC!, animated: true, completion: nil)
        //        })
        //        alertController.addAction(okayDontShowAction)
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okayAction)
        return alertController
    }
    
    func callNumber(phoneNumber: String) {
        if let url = URL(string: "telprompt:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }
        self.contactDelegate?.cannotCallError(message: self.cannotCallError)
    }
    
    func textNumber(phoneNumber: [String]) {
        DispatchQueue.main.async {
            self.textMessageRecipients = phoneNumber
            self.messagingType = .Text
            self.messagingService.delegate = self
            if self.messagingService.canSendText {
                self.textingVC = self.messagingService.configuredMessageComposeViewController(textMessageRecipients: self.textMessageRecipients)
                // Conditionally show Text Warning Alert
                if !self.textWarningFlag {
                    self.delegateViewController.present(self.messageWarningAlert, animated: true, completion: nil)
                } else {
                    self.delegateViewController.present(self.textingVC!, animated: true, completion: nil)
                }
                return
            }
            self.contactDelegate?.cannotTextError(message: self.cannotTextError)
        }
    }
    
    func emailContact(emailAddress: [String]) {
        DispatchQueue.main.async {
            self.emailMessageRecipients = emailAddress
            self.messagingType = .Email
            self.emailService.delegate = self
            if self.emailService.canSendMail {
//                let emailComposeVC = self.emailService.configuredMailComposeViewController(mailRecipients: recipients)
//                self.delegateViewController.present(emailComposeVC, animated: true, completion: nil)
                self.delegateViewController.present(self.messageWarningAlert, animated: true, completion: nil)
                return
            }
            self.contactDelegate?.cannotEmailError(message: self.cannotEmailError)
        }
    }
    
    func makeContactList(from contacts: [FavoritesContact]) -> [String] {
        var contactList = [String]()
        for contact in contacts {
            switch self.messagingType {
            case .Email:
                if let email = contact.emailAddress, !email.isEmpty {
                    contactList.append(email)
                }
            case .Text:
                if let cell = contact.cellphone, !cell.isEmpty {
                    contactList.append(cell)
                }
            }
        }
        return contactList
    }
}
