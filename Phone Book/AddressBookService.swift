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
    func successfullyAddedGroupToAddressBook(groupName: String, isUpdatingGroup: Bool)
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
    var hasGrantedAddressBookAccess : Bool {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .denied, .restricted, .notDetermined:
            return false
        case .authorized:
            return true
        }
    }
    
    init(
        delegate: AddressBookDelegate?=nil,
        contactDelegate: AddContactAddressBookDelegate?=nil,
        groupDelegate: AddGroupAddressBookDelegate?=nil) {
        self.addressBookDelegate = delegate
        self.addContactDelegate = contactDelegate
        self.addGroupDelegate = groupDelegate
    }
    
    /**
     Checks CNContactStore's authorizationStatus & fires AddressBookDelegate callback
    */
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
    
    /**
     Updates CNContactStore with Contact
     - parameter contact: Contact object to add to CNContactStore
    */
    func updateAddressBook(contact: Contact) {
        if !self.contactExistsInAddressBook(contact: contact) {
            self.addNewContactToAddressBook(contact: contact)
        } else {
            self.updateExistingAddressBookContact(contact: contact)
        }
    }
    
    /**
     Returns Bool indicating whether Contact is already in CNContactStore
     - parameter contact: Contact object check existence in CNContactStore
    */
    func contactExistsInAddressBook(contact: Contact) -> Bool {
        guard let contacts = self.fetchFromAddressBook(contact: contact) else { return false }
        for c in contacts {
            if c.givenName == contact.firstName && c.middleName == contact.middleName && c.familyName == contact.lastName {
                return true
            }
        }
        return false
    }
    
    // MARK: - Group Updates
    
    /**
     Checks all CNGroups in CNContactStore and returns a Bool if match is found
     - parameter groupTitle: String representing Group name to compare against
    */
    func groupExistsInAddressBook(groupTitle: String) -> Bool {
        if hasGrantedAddressBookAccess {
            let allGroups = try! contactStore.groups(matching: nil)
            for group in allGroups {
                if group.name == groupTitle {
                    return true
                }
            }
            return false
        }
        return false
    }
    
    /**
     Adds a Group to CNContactStore
     - parameters:
        - contacts: Array of FavoritesContacts to be added to Group
        - groupName: Name of the Group to add the Contacts
    */
    func addGroupToAddressBook(contacts: Array<FavoritesContact>, groupName: String) {
        /*
         * 1. Fetch all CNGroups in CNContactStore
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
        self.addNewGroupAndContactsToAddressBook(contacts: contacts, groupName: groupName)
    }
    
    /**
     Updates title of existing Group
     - parameters:
        - oldTitle: Name of old Group
        - newTitle: New name of Group
        - contacts: Array of FavoritesContacts to add to updated Group
    */
    func updateGroupTitle(from oldTitle: String, to newTitle: String, for contacts: Array<FavoritesContact>)
    {
        var didUpdateTitle = false
        let saveRequest = CNSaveRequest()
        let allGroups = try! contactStore.groups(matching: nil)
        for group in allGroups {
            if group.name == oldTitle {
                // Group exists in ContactStore
                saveRequest.delete(group.mutableCopy() as! CNMutableGroup)
                do {
                    try contactStore.execute(saveRequest)
                    didUpdateTitle = true
                } catch {
                    self.addGroupDelegate?.failedToAddGroupToAddressBook(message: error.localizedDescription)
                    return
                }
            }
        }
        self.addNewGroupAndContactsToAddressBook(contacts: contacts, groupName: newTitle, isUpdatingGroup: didUpdateTitle)
    }
}

private extension AddressBookService {
    /**
     Populates CNMutableContact with Contact info, and conditionally removes old data if info is being updated
    */
    func hydrateAddressBookContact(with contact: Contact, for contactRecord: inout CNMutableContact, isUpdating: Bool) {
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
        if isUpdating { contactRecord.emailAddresses.removeAll() }
        contactRecord.emailAddresses.append(CNLabeledValue(label: CNLabelWork, value: contact.emailAddress as NSString))
        // Work Address
        let workAddress = CNMutablePostalAddress()
        workAddress.street = "\(contact.primaryAddressLine1) \(contact.primaryAddressLine2)"
        // TODO: Break up address components for city, state, zip
        if isUpdating { contactRecord.postalAddresses.removeAll() }
        contactRecord.postalAddresses.append(CNLabeledValue(label: CNLabelWork, value: workAddress))
    }
    
    /**
     Makes and returns a CNMutableContact
     - parameter contact: Contact object used to decorate CNMutableContact properties
    */
    func makeAddressBookContact(with contact: Contact) -> CNMutableContact {
        var contactRecord = CNMutableContact()
        self.hydrateAddressBookContact(with: contact, for: &contactRecord, isUpdating: false)
        return contactRecord
    }
    
    /**
     Adds new CNMutableContact to AddressBook
     - parameters:
        - contactRecord: CNMutableContact to add to CNContactStore
        - identifier: Optional identifier to add to CNSaveRequest container
    */
    func addNewContactToAddressBook(contact: Contact, identifier: String?=nil) {
        let saveRequest = CNSaveRequest()
        let contactRecord = self.makeAddressBookContact(with: contact)
        saveRequest.add(contactRecord, toContainerWithIdentifier: identifier)
        do {
            try contactStore.execute(saveRequest)
            self.addContactDelegate?.successfullyAddedNewContactToAddressBook()
        } catch {
            self.addContactDelegate?.failedToUpdateContactInAddressBook(message: error.localizedDescription)
        }
    }
    
    /**
     Updates existing CNMutableContact in AddressBook
     - parameters:
        - contactRecord: CNMutableContact to add to CNContactStore
        - identifier: Optional identifier to add to CNSaveRequest container
     */
    func updateExistingAddressBookContact(contact: Contact) {
        let saveRequest = CNSaveRequest()
        guard let contactRecords = self.fetchFromAddressBook(contact: contact) else {
            self.addContactDelegate?.failedToUpdateContactInAddressBook(message: "Sorry, something went wrong updating your AddressBook. Please try again later.")
            return
        }
        // Copy retrieved contactRecord, populate info with Contact info, update in CNStore
        var contactRecord = contactRecords.first?.mutableCopy() as! CNMutableContact
        self.hydrateAddressBookContact(with: contact, for: &contactRecord, isUpdating: true)
        saveRequest.update(contactRecord)
        do {
            try self.contactStore.execute(saveRequest)
            self.addContactDelegate?.successfullyUpdatedExistingContactInAddressBook()
        } catch {
            self.addContactDelegate?.failedToUpdateContactInAddressBook(message: error.localizedDescription)
        }
    }
    
    /**
     Fetches all CNContacts in CNContactStore matching specific Contact
     - parameter contact: Contact to match against in the CNContactStore
    */
    func fetchFromAddressBook(contact: Contact) -> Array<CNContact>? {
        do {
            return try contactStore.unifiedContacts(
                matching: CNContact.predicateForContacts(matchingName: contact.lastName),
                keysToFetch:[
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor,
                    CNContactMiddleNameKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactPostalAddressesKey as CNKeyDescriptor
                ]
            )
        } catch {
            return nil
        }
    }
    
    /**
     Create and return CNMutableGroup
     - parameters:
        - groupName: Name of Group
    */
    func createGroup(groupName: String) -> CNMutableGroup {
        let group = CNMutableGroup()
        group.name = groupName
        return group
    }
    
    /**
     Trigger .denied or .restricted authorizationStatus, and conditionally show message
    */
    func triggerDeniedAddressbookAccess() {
        if !previouslyDeniedAddressAccess {
            UserDefaults.standard.set(true, forKey: self.deniedCountKey)
            self.addressBookDelegate?.deniedAddressBookAccess(showMessage: true)
        } else {
            self.addressBookDelegate?.deniedAddressBookAccess(showMessage: false)
        }
    }
    
    /**
     Adds Contacts to Group
     - parameters:
        - contacts: Array of FavoritesContacts to add to Group
        - group: Group to add Contacts to
        - isUpdatingGroup: Bool indicating whether new Group creation is part of updating old Group process; defaults to false
    */
    func add(contacts: Array<FavoritesContact>, to group: CNGroup, isUpdatingGroup: Bool=false) {
        /*
         * 1. Loop through each FavoritesContact in contacts
         * 2. Create CNMutableContact object
         * 3. Check if contact is already in CNContactStore, and remove all instances tha already exist
         * 4. Add CNGroup to CNContactStore, along with array of CNMutableContacts
        */
        for favContact in contacts {
            let contact = Contact(favoriteContact: favContact)
            let addressContact = self.makeAddressBookContact(with: contact)
            let saveMember = CNSaveRequest()
            if contactExistsInAddressBook(contact: contact) {
                let addyContacts = self.fetchFromAddressBook(contact: contact)
                for addyContact in addyContacts! {
                    saveMember.delete(addyContact.mutableCopy() as! CNMutableContact)
                }
            }
            saveMember.addMember(addressContact, to: group)
            saveMember.add(addressContact, toContainerWithIdentifier: nil)
            do {
                try contactStore.execute(saveMember)
            } catch {
                self.addGroupDelegate?.failedToAddGroupToAddressBook(message: error.localizedDescription)
                return
            }
        }
        self.addGroupDelegate?.successfullyAddedGroupToAddressBook(groupName: group.name, isUpdatingGroup: isUpdatingGroup)
    }
    
    /**
     Adds New Group and Contacts to AddressBook
     - parameters:
        - contacts: Array of FavoritesContact to add to Group
        - groupName: Name to assign to new Group
        - isUpdatingGroup: Bool indicating whether new Group creation is part of updating old Group process; defaults to false
    */
    func addNewGroupAndContactsToAddressBook(contacts: Array<FavoritesContact>, groupName: String, isUpdatingGroup: Bool=false) {
        let newGroup = self.createGroup(groupName: groupName)
        let newGroupSave = CNSaveRequest()
        newGroupSave.add(newGroup, toContainerWithIdentifier: nil)
        do {
            try contactStore.execute(newGroupSave)
        } catch {
            self.addGroupDelegate?.failedToAddGroupToAddressBook(message: error.localizedDescription)
            return
        }
        self.add(contacts: contacts, to: newGroup, isUpdatingGroup: isUpdatingGroup)
    }
}
