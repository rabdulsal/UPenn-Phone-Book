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
    func deniedAddressBookAccess()
    func successfullyUpdatedContactInAddressBook()
    func failedToUpdateContactInAddressBook()
    func contactAlreadyExistsInAddressBook() // TODO: Will eventually remove once updating functionality
}

class AddressBookService {
    
    let contactStore = CNContactStore()
    var addressBookDelegate: AddressBookDelegate?
    
    init(delegate: AddressBookDelegate) {
        self.addressBookDelegate = delegate
    }
    
    func checkAddressBookAuthorizationStatus() {
        // If Contact is NOT in AddressBook
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .denied, .restricted:
            // Display "Can't Add Contact Alert"
            self.addressBookDelegate?.deniedAddressBookAccess()
        case .authorized:
            //2 Add to AddressBook
            self.addressBookDelegate?.authorizedAddressBookAccess()
        case .notDetermined:
            //3 Display alert for AddressBook access
            self.contactStore.requestAccess(for: .contacts, completionHandler: { (access, error) in
                if access {
                    self.addressBookDelegate?.authorizedAddressBookAccess()
                } else {
                    self.addressBookDelegate?.deniedAddressBookAccess()
                }
            })
        }
    }
    
    func updateAddressBook(contact: Contact) {
        if !self.contactExistsInAddressBook(contact: contact) {
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
            // Email - TODO: Fix error
            //        contactRecord.emailAddresses = [
            //            CNLabeledValue(label: CNLabelWork, value: contact.emailAddress)
            //        ]
            // Work Address
            let workAddress = CNMutablePostalAddress()
            workAddress.street = contact.primaryAddressLine1
            // TODO: Break up address components for city, state, zip
            contactRecord.postalAddresses = [
                CNLabeledValue(label: CNLabelWork, value: workAddress)
            ]
            let saveRequest = CNSaveRequest()
            saveRequest.add(contactRecord, toContainerWithIdentifier: nil)
            // TODO: Wrap in try-catch block and fire off delegate methods
            try! contactStore.execute(saveRequest)
            self.addressBookDelegate?.successfullyUpdatedContactInAddressBook()
        } else {
            self.addressBookDelegate?.contactAlreadyExistsInAddressBook()
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
}
