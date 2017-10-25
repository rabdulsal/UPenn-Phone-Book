//
//  FavoritesService.swift
//  Phone Book
//
//  Created by Admin on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FavoritesService {
    
    static var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    static func saveContact(with contact: Contact, completion: ((_ contact: FavoritesContact)->Void)?=nil) {
        guard let appDelegate = FavoritesService.appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let favContact = FavoritesContact(context: managedContext)
        // TODO: Create new save func from here
        favContact.firstName = contact.firstName
        favContact.lastName = contact.lastName
        favContact.fullName = contact.fullName
        favContact.middleName = contact.middleName
        favContact.phonebookID = Double(contact.phonebookID)
        favContact.jobTitle = contact.jobTitle
        favContact.department = contact.department
        favContact.pagerNumber = contact.pagerNumber
        favContact.displayPagerNumber = contact.displayPagerNumber
        favContact.pagerEmail = contact.pagerEmail
        favContact.emailAddress = contact.emailAddress
        favContact.primaryAddressLine1 = contact.primaryAddressLine1
        favContact.primaryAddressLine2 = contact.primaryAddressLine2
        favContact.primaryTelephone = contact.primaryTelephone
        favContact.primaryFax = contact.primaryFax
        favContact.displayPrimaryFax = contact.displayPrimaryFax
        favContact.cellphone = contact.cellphone
        favContact.displayCellPhone = contact.displayCellPhone
        favContact.cellEmail = contact.cellEmail
        favContact.isDisabled = Double(contact.isDisabled)
        appDelegate.saveContext()
        if let _completion = completion {
            _completion(favContact)
        }
    }
    
    static func updateContact(with contact: Contact, completion: ((_ favContact: FavoritesContact)->Void)?=nil) {
        
    }
}
