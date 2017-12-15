
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

/**
 - parameters:
 - contact: An option FavoritesContact is successfully added/cached.
 - errorString: An optional String representing an error if the Contact cannot be cached.
 */
typealias AddContactHandler = (_ contact: FavoritesContact?, _ errorString: String?)->Void

/**
 - parameters:
 - success: Bool returning a failed/successful execution
 */
typealias SuccessHandler = (_ success: Bool)->Void

class FavoritesGroup {
    var title: String
    var favoritedContacts = Array<FavoritesContact>()
    
    init(with favorite: FavoritesContact) {
        self.title = favorite.groupName!
        self.favoritedContacts.append(favorite)
    }
}

class FavoritesService {
    
    static var favoritesGroupsCount : Int {
        return self.favoritesGroupHash.count
    }
    
    /**
     Empty all hash tables and reload/bucket data from CoreData
     */
    static func loadFavoritesData() {
        self.favoritesSectionHash.removeAll()
        self.favoritesGroupHash.removeAll()
        let allFavorites = self.getAllFavorites()
        for favorite in allFavorites {
            self.bucketFavoritesContacts(with: favorite)
        }
    }
    
    /**
     Convenience method to add a Contact to a new Favorites Group. Method returns an error if the groupTitle is not unique.
     
    - parameters:
        - contact: The contact object to be added the Favorites Group
        - groupTitle: String representing the title of the New Favorites Group.
        - completion: Invoked upon successful/failed attempt to add to Favorites cache.
    */
    static func addNewFavorite(_ contact: Contact, groupTitle: String, completion: @escaping (AddContactHandler)) {
        
        guard let _ = self.favoritesGroupHash[groupTitle] else {
            self.addToFavorites(contact, groupTitle: groupTitle, completion: completion)
            return
        }
        completion(nil,"Please use a unique Favorites Group Name.")
    }
    
    
    static func addToFavorites(_ contact: Contact, groupTitle: String, completion: @escaping (AddContactHandler)) {
        /*
         When Adding to Favorites, must always search for contact to:
         1: Ensure the most-recent Contact data is being stored,
         2: Ensure that when favoriting from either the ContactList or ContactDetails views, all the necessary Contact data is being cached
         */
        let phoneID = String(describing: contact.phonebookID)
        self.searchService.makeContactSearchRequest(with: phoneID) { (_contact, error) in
            if let e = error {
                completion(nil,e.localizedDescription)
            } else {
                guard
                    let c = _contact,
                    let favContact = self.makeFavoriteContact(with: c, groupTitle: groupTitle) else { return }
                self.bucketFavoritesContacts(with: favContact)
                completion(favContact,nil)
            }
        }
    }
    
    /**
     Convenience method to add particular FavoritesContact to an existing FavoritesGroup
     
    - parameters:
        - contact: Contact object to be added to the Favorites cache.
        - groupTitle: String representing the title of the existing Favorites Group.
        - completion: Invoked upon successful/failed attempt to add to Favorites cache.
     */
    static func addFavoriteContactToExistingGroup(contact: Contact, groupTitle: String, completion: @escaping (SuccessHandler)) {
        self.addToFavorites(contact, groupTitle: groupTitle) { (favContact, errorString) in
            if let _ = errorString {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /**
     Convenience method to removeFromFavorites using a Contact
     
    - parameters:
        - contact: Contact object to be removed from the Favorites cache.
        - completion: Invoked upon successful/failed attempt to remove from Favorites cache.
     */
    static func removeFromFavorites(contact: Contact, completion: (SuccessHandler)) {
        guard let appDelegate = self.appDelegate, let managedContext = self.managedContext else { return }
        if let favContact = self.getFavoriteContact(contact) {
            managedContext.delete(favContact)
            appDelegate.saveContext()
            self.loadFavoritesData()
            completion(true)
        }
        completion(false)
    }
    
    /**
     Convenience method to removeFromFavorites using a FavoritesContact
     
     - parameters:
        - favoriteContact: FavoriteContact object to be removed from the Favorites cache.
        - completion: Invoked upon successful/failed attempt to remove from Favorites cache.
     */
    static func removeFromFavorites(favoriteContact: FavoritesContact, completion: (SuccessHandler)) {
        guard let appDelegate = self.appDelegate, let managedContext = self.managedContext else { return }
        managedContext.delete(favoriteContact)
        appDelegate.saveContext()
        self.loadFavoritesData()
        completion(true)
    }
    
    /**
     Convenience method fetches and returns FavoritesContact from CoreData using a Contact
     
     - parameter contact: Contact object to be fetched from CoreData
     */
    static func getFavoriteContact(_ contact: Contact) -> FavoritesContact? {
        let faveContact = self.allFavoritedContacts.filter { $0.phonebookID == Double(contact.phonebookID) }.first
        if let fave = faveContact {
            return fave
        }
        return nil
    }
    
    static func updateFavoritedStatus(_ contact: Contact) -> Bool {
        return self.allFavoritedContacts.filter { $0.phonebookID == Double(contact.phonebookID) }.first != nil
    }
    
    /**
     Factory method to create a FavoritesContact CoreData object & store into persistence
     
     - parameters
        - contact: Contact object used to create a FavoritesContact object and store into CoreData
        - groupTitle: Title String to set to FavoritesContact groupName attribute
     */
    static func makeFavoriteContact(with contact: Contact, groupTitle: String) -> FavoritesContact? {
        guard let appDelegate = self.appDelegate, let managedContext = self.managedContext else { return nil }
        let favContact = FavoritesContact(context: managedContext)
        favContact.firstName                = contact.firstName
        favContact.lastName                 = contact.lastName
        favContact.fullName                 = contact.fullName
        favContact.middleName               = contact.middleName
        favContact.phonebookID              = Double(contact.phonebookID)
        favContact.jobTitle                 = contact.jobTitle
        favContact.department               = contact.department
        favContact.pagerNumber              = contact.pagerNumber
        favContact.displayPagerNumber       = contact.displayPagerNumber
        favContact.pagerEmail               = contact.pagerEmail
        favContact.emailAddress             = contact.emailAddress
        favContact.primaryAddressLine1      = contact.primaryAddressLine1
        favContact.primaryAddressLine2      = contact.primaryAddressLine2
        favContact.displayPrimaryTelephone  = contact.displayPrimaryTelephone
        favContact.primaryTelephone         = contact.primaryTelephone
        favContact.primaryFax               = contact.primaryFax
        favContact.displayPrimaryFax        = contact.displayPrimaryFax
        favContact.cellphone                = contact.cellphone
        favContact.displayCellPhone         = contact.displayCellPhone
        favContact.cellEmail                = contact.cellEmail
        favContact.isDisabled               = Double(contact.isDisabled)
        favContact.groupName                = groupTitle
        favContact.groupPosition            = self.generateFavoritesGroupPosition(groupTitle: groupTitle)
        appDelegate.saveContext()
        return favContact
    }
    
    /**
     Convenience method to return Array of all FavoritesGroup titles
     */
    static func getAllFavoritesGroups() -> Array<String> {
        self.loadFavoritesData()
        return Array(self.favoritesGroupHash.keys)
    }
    
    /**
     Convenience method to FavoritesGroup Title from index
     */
    static func getFavoritesGroupTitle(for index: Int) -> String? {
        return self.favoritesSectionHash[index]
    }
    
    /**
     Convenience method to return Array of FavoritedContacts based on Section, when displaying in TableViews
     */
    static func getFavoritesGroup(for section: Int) -> Array<FavoritesContact>? {
        if
            let groupTitle = self.favoritesSectionHash[section],
            let favsGroup = self.favoritesGroupHash[groupTitle] {
            return favsGroup.favoritedContacts
        }
        return nil
    }
    
    /**
     Convenience method to return single FavoriteContact based on Section, when displaying in TableViews
     
    - parameter indexPath: IndexPath object providing section & row from which to fetch/return FavoriteContact
     */
    static func getFavoriteContact(with indexPath: IndexPath) -> FavoritesContact? {
        guard let favContacts = self.getFavoritesGroup(for: indexPath.section) else { return nil }
        return favContacts[indexPath.row]
    }
    
    /**
     Convenience method to return Count for each FavoritesGroup when displaying in TableViews by Section
     */
    static func getFavoritesGroupCount(for section: Int) -> Int {
        guard let favContacts = self.getFavoritesGroup(for: section) else { return 0 }
        return favContacts.count
    }
    
    /**
     Convenience method for re-arranging rows in FavortiesViewController
     
    - parameters:
        - source: IndexPath of the source FavoritesGroup contacts to fetch contact to be moved.
        - destination: IndexPath of the destination FavoritesGroup contacts to place the contact being moved.
     */
    static func moveContact(from source: IndexPath, to destination: IndexPath) {
        guard
            let favContact = FavoritesService.getFavoriteContact(with: source),
            let appDelegate = FavoritesService.appDelegate else { return }
        /*
         Get source Group using indexPath.section
         Remove favContact from that Group using indexPath.row
         Get destination Group using indexPath.section
         Insert favContact into new group using indexPath.row
         Update favContact.groupName to be destination favGroup.title
         Save context
         */
        var sourceGroup = self.getFavoritesGroup(for: source.section)
        var destinationGroup = self.getFavoritesGroup(for: destination.section)
        if sourceGroup! == destinationGroup! {
            destinationGroup?.remove(at: source.row)
        } else {
            sourceGroup?.remove(at: source.row)
        }
        destinationGroup?.insert(favContact, at: destination.row)
        favContact.groupName = self.favoritesSectionHash[destination.section]
        favContact.groupPosition = Double(destination.row)
        if let group = destinationGroup {
            for index in 0..<group.count {
                let favContact = group[index]
                favContact.groupPosition = Double(index)
            }
        }
        appDelegate.saveContext()
        self.loadFavoritesData()
    }
}

private extension FavoritesService {
    static var appDelegate: AppDelegate? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate
    }
    
    static var managedContext: NSManagedObjectContext? {
        guard let appDelegate = self.appDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    static var searchService = ContactsSearchService()
    
    /**
     Returns all FavoritesContacts from CoreData, unbucketed
     */
    static var allFavoritedContacts: Array<FavoritesContact> {
        return self.getAllFavorites()
    }
    
    /**
     Dictionary intended to take a Section Int & return Group title string, which can key into the favoritesHash
     */
    static var favoritesSectionHash = Dictionary<Int,String>()
    
    /**
     Dictionary intended to expedite retrieving FavoritesGroup by Title String
     */
    static var favoritesGroupHash = Dictionary<String,FavoritesGroup>()
    
    /**
     Returns an Array of all FavoritesContacts loaded from CoreData
     */
    static func getAllFavorites() -> Array<FavoritesContact> {
        guard let managedContext = self.managedContext else { return [] }
        
        do {
            return try managedContext.fetch(FavoritesContact.fetchRequest())
        } catch let error as NSError {
            // TODO: Add Error handling to completion
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    /**
     Create a FavoritesContact groupPosition for FavoritesGroup using a groupTitle
     */
    static func generateFavoritesGroupPosition(groupTitle: String) -> Double {
        guard
            let favorites = favoritesGroupHash[groupTitle]?.favoritedContacts else { return 0.0 }
        return Double(favorites.count)
    }
    
    /**
     Add favoriteContact into an existing FavoritesGroup, or create a new Group and add to that while updating favoritesGroupHash & favoritesSectionHash
     
     - parameters:
        - favContact: FavoritesContact to be added to FavoritesGroup
     */
    static func bucketFavoritesContacts(with favContact: FavoritesContact) {
        /*
         If adding to an existing group:
         1. Loop through favGroup's favorites
         2. Check if favContact is less than current contact, insert it, stop looping
         3. Otherwise if at the end for the favGroups just append the contact
         */
        if let favGroup = favoritesGroupHash[favContact.groupName!] {
            let last = favGroup.favoritedContacts.count-1
            for i in 0...last {
                if favContact.groupPosition < favGroup.favoritedContacts[i].groupPosition {
                    favGroup.favoritedContacts.insert(favContact, at: i)
                    break
                } else if i==last {
                    favGroup.favoritedContacts.append(favContact)
                }
            }
        } else {
            let favGroup = FavoritesGroup(with: favContact)
            favoritesGroupHash[favContact.groupName!] = favGroup
            self.favoritesSectionHash[self.favoritesGroupHash.count-1] = favContact.groupName!
        }
    }
}
