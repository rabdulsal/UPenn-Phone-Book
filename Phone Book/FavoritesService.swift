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
    
    static var allFavoritedContacts: Array<FavoritesContact> {
        return self.getAllFavorites()
    }
    
    static func addToFavorites(_ contact: Contact, completion: ((_ contact: FavoritesContact)->Void)?=nil) {
        guard let appDelegate = FavoritesService.appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let favContact = FavoritesContact(context: managedContext)
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
    
    static func removeFromFavorites(_ contact: Contact, completion: ((_ success: Bool)->Void)?=nil) {
        guard let appDelegate = FavoritesService.appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        if let favContact = self.getFavoriteContact(contact) {
            managedContext.delete(favContact)
            appDelegate.saveContext()
            if let _completion = completion {
                _completion(true)
            }
        }
    }
    
    static func getAllFavorites() -> Array<FavoritesContact> {
        guard let appDelegate = FavoritesService.appDelegate else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            return try managedContext.fetch(FavoritesContact.fetchRequest())
        } catch let error as NSError {
            // TODO: Add Error handling to completion
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    static func getFavoriteContact(_ contact: Contact) -> FavoritesContact? {
        
        guard let appDelegate = FavoritesService.appDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        var favorites = [FavoritesContact]()
        
        do {
            favorites = try managedContext.fetch(FavoritesContact.fetchRequest())
            let faveContact = favorites.filter { $0.fullName == contact.fullName }.first
            if let fave = faveContact {
                return fave
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    static func updateFavoritesStatus(_ contact: Contact) -> Bool {
        return self.allFavoritedContacts.filter { $0.fullName == contact.fullName }.first != nil
        
    }
}
