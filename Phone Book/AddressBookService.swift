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
}

protocol AddContactAddressBookDelegate {
    func failedToUpdateContactInAddressBook(message: String)
    func successfullyAddedNewContactToAddressBook()
    func successfullyUpdatedExistingContactInAddressBook()
}

protocol AddGroupAddressBookDelegate {
    func successfullyAddedGroupToAddressBook(groupName: String)
    func failedToAddGroupToAddressBook(message: String)
}

class AddressBookService {
    
    let deniedCountKey = "deniedCountKey"
    let contactStore = CNContactStore()
    var addressBookDelegate: AddressBookDelegate?
    var addContactDelegate: AddContactAddressBookDelegate?
    var addGroupDelegate: AddGroupAddressBookDelegate?
    var previouslyDeniedAddressAccess : Bool {
        guard let denied = UserDefaults.standard.value(forKey: self.deniedCountKey) as? Bool else { return false }
        return denied
    }
    
    init(
        delegate: AddressBookDelegate?=nil,
        contactDelegate: AddContactAddressBookDelegate?=nil,
        groupDelegate: AddGroupAddressBookDelegate?=nil) {
        self.addressBookDelegate = delegate
        self.addContactDelegate = contactDelegate
        self.addGroupDelegate = groupDelegate
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
    
    // MARK: - Contact Updates
    
    func updateAddressBook(contact: Contact) {
        let contactRecord = self.makeAddressBookContact(with: contact)
        if !self.contactExistsInAddressBook(contact: contact) {
            self.addNewContactToAddressBook(contactRecord: contactRecord)
        } else {
            self.updateExistingAddressBookContact(contactRecord: contactRecord)
        }
    }
    
    func contactExistsInAddressBook(contact: Contact) -> Bool {
        let contacts = try! contactStore.unifiedContacts(
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
    
    func addNewContactToAddressBook(contactRecord: CNMutableContact, identifier: String?=nil) {
        let saveRequest = CNSaveRequest()
        saveRequest.add(contactRecord, toContainerWithIdentifier: identifier)
        do {
            try contactStore.execute(saveRequest)
            self.addContactDelegate?.successfullyAddedNewContactToAddressBook()
        } catch {
            self.addContactDelegate?.failedToUpdateContactInAddressBook(message: error.localizedDescription)
        }
    }
    
    func updateExistingAddressBookContact(contactRecord: CNMutableContact) {
        let saveRequest = CNSaveRequest()
        saveRequest.update(contactRecord)
        do {
            try self.contactStore.execute(saveRequest)
            self.addContactDelegate?.successfullyUpdatedExistingContactInAddressBook()
        } catch {
            self.addContactDelegate?.failedToUpdateContactInAddressBook(message: error.localizedDescription)
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
    
    // MARK: - Group Updates
    
    func createGroup(groupName: String) -> CNMutableGroup {
        let group = CNMutableGroup()
        group.name = groupName
        return group
    }
    
    func addGroupToAddressBook(contacts: Array<FavoritesContact>, groupName: String) {
        /*
         * 1. Fetch all CNGroups in CNStore
         * 2. Loop through all groups to see if groupName exists
         * 3. If Yes, add Contacts to respective Group
         * 4. If No, create a new CNMutableGroup with groupName and add Contacts to new Group
         */
        let allGroups = try! contactStore.groups(matching: nil)
        for group in allGroups {
            if group.name == groupName {
                // Group exists in ContactStore
                self.add(contacts: contacts, to: group)
                return
            }
        }
        // Group doesn't exist in ContactStore
        let newGroup = self.createGroup(groupName: groupName)
        let newGroupSave = CNSaveRequest()
        newGroupSave.add(newGroup, toContainerWithIdentifier: nil)
        do {
            try contactStore.execute(newGroupSave)
        } catch {
            self.addGroupDelegate?.failedToAddGroupToAddressBook(message: error.localizedDescription)
            return
        }
        self.add(contacts: contacts, to: newGroup)
    }
    
    func add(contacts: Array<FavoritesContact>, to group: CNGroup) {
        // Loop through each Contact add to passed-in group
        for contact in contacts {
            let addressContact = self.makeAddressBookContact(with: Contact(favoriteContact: contact))
            let saveMember = CNSaveRequest()
            saveMember.addMember(addressContact, to: group)
            saveMember.add(addressContact, toContainerWithIdentifier: nil)
            do {
                try contactStore.execute(saveMember)
            } catch {
                self.addGroupDelegate?.failedToAddGroupToAddressBook(message: error.localizedDescription)
                return
            }
        }
        self.addGroupDelegate?.successfullyAddedGroupToAddressBook(groupName: group.name)
    }
}
