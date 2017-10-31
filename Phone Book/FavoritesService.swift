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

struct FavoritesGroup {
    var title: String
    var favoritedContacts = Array<FavoritesContact>()
    
    init(with favorite: FavoritesContact) {
        self.title = favorite.groupName!
        self.favoritedContacts.append(favorite)
    }
}

class FavoritesService {
    
    private static var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private static var searchService = ContactsSearchService()
    
    static var allFavoritedContacts: Array<FavoritesContact> {
        return self.getAllFavorites()
    }
    
    /***
     * Intended to take a Section Int & return Group title string, which can key into the favoritesHash
     */
    static var favoritesSectionHash = Dictionary<Int,String>()
    
    /***
     * Intended to expedite retrieving FavoritesGroup by Title String
     */
    static var favoritesGroupHash = Dictionary<String,FavoritesGroup>()
    
    static func addToFavorites(_ contact: Contact, groupTitle: String, completion: @escaping ((_ contact: FavoritesContact)->Void)) {
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
                    let favContact = self.makeFavoriteContact(with: c, groupTitle: groupTitle) else { return }
                
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
    
    static func makeFavoriteContact(with contact: Contact, groupTitle: String) -> FavoritesContact? {
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
        favContact.groupName            = groupTitle
        appDelegate.saveContext()
        return favContact
    }
    
    static func makeFavoritesGroups() {
        for contact in self.allFavoritedContacts {
            if var favGroup = favoritesGroupHash[contact.groupName!] {
                favGroup.favoritedContacts.append(contact)
            } else {
                let favGroup = FavoritesGroup(with: contact)
                favoritesGroupHash[contact.groupName!] = favGroup
                self.favoritesSectionHash[self.favoritesSectionHash.count+1] = contact.groupName!
            }
        }
    }
    
    /***
     * Convenience method to return Array of FavoritedContacts based on Section, when displaying in TableViews
     */
    
    static func getFavoritesGroup(for section: Int) -> Array<FavoritesContact>? {
        if
            let groupTitle = self.favoritesSectionHash[section],
            let favsGroup = self.favoritesGroupHash[groupTitle] {
            return favsGroup.favoritedContacts
        }
        return nil
    }
    
    static func getFavoriteContact(with indexPath: IndexPath) -> FavoritesContact? {
        guard let favContacts = self.getFavoritesGroup(for: indexPath.section) else { return nil }
        return favContacts[indexPath.row]
    }
    
    /***
     * Convenience method to return Count for each FavoritesGroup when displaying in TableViews
     */
    static func getFavoritesGroupCount(for section: Int) -> Int {
        guard let favContacts = self.getFavoritesGroup(for: section) else { return 0 }
        return favContacts.count
    }
}
