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
    func cannotEmailError(message: String)
    func cannotTextError(message: String)
    func cannotCallError(message: String)
}

class ContactService {
    let cannotEmailError = "Sorry, something went wrong. Cannot send email at this time."
    let cannotTextError = "Sorry, something went wrong. Cannot send text at this time."
    let cannotCallError = "Sorry, something went wrong. Cannot make call at this time."
    let messagingService = MessagingService()
    let emailService = EmailService()
    var delegateViewController: UIViewController
    var contact: Contact?
    var favoriteContacts = [FavoritesContact]()
    var contactDelegate: ContactServicable?
    
    init(viewController: UIViewController, contact: Contact, delegate: ContactServicable) {
        self.delegateViewController = viewController
        self.contact = contact
        self.contactDelegate = delegate
    }
    
    init(viewController: UIViewController, contacts: [FavoritesContact], delegate: ContactServicable) {
        self.delegateViewController = viewController
        self.favoriteContacts = contacts
        self.contactDelegate = delegate
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
        self.textNumber(phoneNumber: self.makeTextNumberList(from: self.favoriteContacts))
    }
    
    func emailGroup() {
        self.emailContact(emailAddress: self.makeEmailList(from: self.favoriteContacts))
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

fileprivate extension ContactService {
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
            let recipients = phoneNumber
            if self.messagingService.canSendText {
                let messageComposeVC = self.messagingService.configuredMessageComposeViewController(textMessageRecipients: recipients)
                self.delegateViewController.present(messageComposeVC, animated: true, completion: nil)
                return
            }
            self.contactDelegate?.cannotTextError(message: self.cannotTextError)
        }
    }
    
    func emailContact(emailAddress: [String]) {
        DispatchQueue.main.async {
            let recipients = emailAddress
            if self.emailService.canSendMail {
                let emailComposeVC = self.emailService.configuredMailComposeViewController(mailRecipients: recipients)
                self.delegateViewController.present(emailComposeVC, animated: true, completion: nil)
                return
            }
            self.contactDelegate?.cannotEmailError(message: self.cannotEmailError)
        }
    }
    
    func makeEmailList(from contacts: [FavoritesContact]) -> [String] {
        var emailList = [String]()
        for contact in contacts {
            if let email = contact.emailAddress, !email.isEmpty {
                emailList.append(email)
            }
        }
        return emailList
    }
    
    func makeTextNumberList(from contacts: [FavoritesContact]) -> [String] {
        var textList = [String]()
        for contact in contacts {
            if let cell = contact.cellphone, !cell.isEmpty {
                textList.append(cell)
            }
        }
        return textList
    }
}
