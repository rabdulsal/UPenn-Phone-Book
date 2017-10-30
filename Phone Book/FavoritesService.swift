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
    
    private static var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private static var searchService = ContactsSearchService()
    
    static var allFavoritedContacts: Array<FavoritesContact> {
        return self.getAllFavorites()
    }
    
    static func addToFavorites(_ contact: Contact, completion: @escaping ((_ contact: FavoritesContact)->Void)) {
        /*
         * When Adding to Favorites, must always search for contact to:
         * 1: Ensure the most-recent Contact data is being stored,
         * 2: Ensure that when favoriting from either the ContactList or ContactDetials views, all the necessary Contact data is being cached
         */
        
        let phoneID = String(describing: contact.phonebookID)
        self.searchService.makeContactSearchRequest(with: phoneID) { (_contact, error) in
            if let e = error {
                // TODO: Bubble error up to VC
            } else {
                guard
                    let c = _contact,
                    let favContact = self.makeFavoriteContact(with: c) else { return }
                
                completion(favContact)
            }
            // TODO: Provide error-related completion
        }
    }
    
    static func removeFromFavorites(_ contact: Contact, completion: ((_ success: Bool)->Void)) {
        guard let appDelegate = FavoritesService.appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        if let favContact = self.getFavoriteContact(contact) {
            managedContext.delete(favContact)
            appDelegate.saveContext()
            completion(true)
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
    
    static func makeFavoriteContact(with contact: Contact) -> FavoritesContact? {
        guard let appDelegate = FavoritesService.appDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        let favContact = FavoritesContact(context: managedContext)
        favContact.firstName            = contact.firstName
        favContact.lastName             = contact.lastName
        favContact.fullName             = contact.fullName
        favContact.middleName           = contact.middleName
        favContact.phonebookID          = Double(contact.phonebookID)
        favContact.jobTitle             = contact.jobTitle
        favContact.department           = contact.department
        favContact.pagerNumber          = contact.pagerNumber
        favContact.displayPagerNumber   = contact.displayPagerNumber
        favContact.pagerEmail           = contact.pagerEmail
        favContact.emailAddress         = contact.emailAddress
        favContact.primaryAddressLine1  = contact.primaryAddressLine1
        favContact.primaryAddressLine2  = contact.primaryAddressLine2
        favContact.primaryTelephone     = contact.primaryTelephone
        favContact.primaryFax           = contact.primaryFax
        favContact.displayPrimaryFax    = contact.displayPrimaryFax
        favContact.cellphone            = contact.cellphone
        favContact.displayCellPhone     = contact.displayCellPhone
        favContact.cellEmail            = contact.cellEmail
        favContact.isDisabled           = Double(contact.isDisabled)
        appDelegate.saveContext()
        return favContact
    }
}
