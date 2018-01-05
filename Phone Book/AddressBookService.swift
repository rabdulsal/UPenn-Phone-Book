//
//  AddressBookService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 12/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import Contacts
import AddressBook
import UIKit

protocol AddressBookDelegate {
    func authorizedAddressBookAccess()
    func deniedAddressBookAccess(showMessage: Bool)
    func failedToUpdateContactInAddressBook(message: String)
    func successfullyAddedNewContactToAddressBook()
    func successfullyUpdatedExistingContactInAddressBook()
}

class AddressBookService {
    
    let deniedCountKey = "deniedCountKey"
    let contactStore = CNContactStore()
    var addressBookDelegate: AddressBookDelegate?
    var previouslyDeniedAddressAccess : Bool {
        guard let denied = UserDefaults.standard.value(forKey: self.deniedCountKey) as? Bool else { return false }
        return denied
    }
    
    init(delegate: AddressBookDelegate) {
        self.addressBookDelegate = delegate
    }
    
    func checkAddressBookAuthorizationStatus() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .denied, .restricted:
            self.triggerDeniedAddressbookAccess()
        case .authorized:
            self.addressBookDelegate?.authorizedAddressBookAccess()
        case .notDetermined:
            self.contactStore.requestAccess(for: .contacts, completionHandler: { (access, error) in
                DispatchQueue.main.async {
                    if access {
                        self.addressBookDelegate?.authorizedAddressBookAccess()
                    } else {
                        self.triggerDeniedAddressbookAccess()
                    }
                }
            })
        }
    }
    
    func updateAddressBook(contact: Contact) {
        let contactRecord = self.makeAddressBookContact(with: contact)
        if !self.contactExistsInAddressBook(contact: contact) {
            self.addNewContactToAddressBook(contactRecord: contactRecord)
            self.addressBookDelegate?.successfullyAddedNewContactToAddressBook()
        } else {
            self.updateExistingAddressBookContact(contactRecord: contactRecord)
            self.addressBookDelegate?.successfullyUpdatedExistingContactInAddressBook()
        }
    }
    
    func contactExistsInAddressBook(contact: Contact) -> Bool {
        let store = CNContactStore()
        let contacts = try! store.unifiedContacts(
            matching: CNContact.predicateForContacts(matchingName: contact.lastName),
            keysToFetch:[
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor
            ]
        )
        for c in contacts {
            if c.givenName == contact.firstName && c.middleName == contact.middleName && c.familyName == contact.lastName {
                return true
            }
        }
        return false
    }
    
    func makeAddressBookContact(with contact: Contact) -> CNMutableContact {
        let contactRecord = CNMutableContact()
        // Name
        contactRecord.givenName = contact.firstName
        contactRecord.middleName = contact.middleName
        contactRecord.familyName = contact.lastName
        // Phone Numbers
        contactRecord.phoneNumbers = [
            // Main Phone
            CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: contact.displayPrimaryTelephone)),
            // Mobile Phone
            CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: contact.displayCellPhone))
        ]
        // Email
        contactRecord.emailAddresses.append(CNLabeledValue(label: CNLabelWork, value: contact.emailAddress as NSString))
        // Work Address
        let workAddress = CNMutablePostalAddress()
        workAddress.street = contact.primaryAddressLine1
        // TODO: Break up address components for city, state, zip
        contactRecord.postalAddresses.append(CNLabeledValue(label: CNLabelWork, value: workAddress))
        return contactRecord
    }
    
    func addNewContactToAddressBook(contactRecord: CNMutableContact) {
        let saveRequest = CNSaveRequest()
        saveRequest.add(contactRecord, toContainerWithIdentifier: nil)
        do {
            try contactStore.execute(saveRequest)
        } catch {
            self.addressBookDelegate?.failedToUpdateContactInAddressBook(message: error.localizedDescription)
        }
    }
    
    func updateExistingAddressBookContact(contactRecord: CNMutableContact) {
        let saveRequest = CNSaveRequest()
        saveRequest.update(contactRecord)
        do {
            try self.contactStore.execute(saveRequest)
        } catch {
            self.addressBookDelegate?.failedToUpdateContactInAddressBook(message: error.localizedDescription)
        }
    }
    
    func triggerDeniedAddressbookAccess() {
        if !previouslyDeniedAddressAccess {
            UserDefaults.standard.set(true, forKey: self.deniedCountKey)
            self.addressBookDelegate?.deniedAddressBookAccess(showMessage: true)
        } else {
            self.addressBookDelegate?.deniedAddressBookAccess(showMessage: false)
        }
    }
}
