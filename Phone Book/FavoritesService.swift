
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

class FavoritesGroup {
    var title: String
    var favoritedContacts = Array<FavoritesContact>()
    
    init(with favorite: FavoritesContact) {
        self.title = favorite.groupName!
        self.favoritedContacts.append(favorite) // TODO: Append favorite at favorite.index
    }
}

class FavoritesService {
    
    static var favoritesGroupsCount : Int {
        return self.favoritesGroupHash.count
    }
    
    /***
     * Empty all hash tables and reload/bucket data from CoreData
     */
    static func loadFavoritesData() {
        self.favoritesSectionHash.removeAll()
        self.favoritesGroupHash.removeAll()
        let allFavorites = self.getAllFavorites()
        for favorite in allFavorites {
            self.bucketFavoritesContacts(with: favorite)
        }
    }
    
    static func addToFavorites(_ contact: Contact, groupTitle: String, completion: @escaping ((_ contact: FavoritesContact?, _ errorString: String?)->Void)) {
        /*
         * When Adding to Favorites, must always search for contact to:
         * 1: Ensure the most-recent Contact data is being stored,
         * 2: Ensure that when favoriting from either the ContactList or ContactDetials views, all the necessary Contact data is being cached
         */
        guard let _ = self.favoritesGroupHash[groupTitle] else {
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
            return
        }
        completion(nil,"Please use a unique Favorites Group Name.")
    }
    
    /***
     * Convenience method to add particular FavoritesContact to existing FavoritesGroup using indexPath.section
     */
    static func addFavoriteContactToExistingGroup(contact: Contact, groupTitle: String, completion: @escaping ((_ success: Bool)->Void)) {
        self.addToFavorites(contact, groupTitle: groupTitle) { (favContact) in
            // TODO: Create Error logic
            completion(true)
        }
    }
    
    /***
     * Convenience method to removeFromFavorites using a Contact
     */
    static func removeFromFavorites(contact: Contact, completion: ((_ success: Bool)->Void)) {
        guard let appDelegate = FavoritesService.appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        if let favContact = self.getFavoriteContact(contact) {
            managedContext.delete(favContact)
            appDelegate.saveContext()
            self.loadFavoritesData()
            completion(true)
        }
        completion(false)
    }
    
    /***
     * Convenience method to removeFromFavorites using a FavoritesContact
     */
    static func removeFromFavorites(favoriteContact: FavoritesContact, completion: ((_ success: Bool)->Void)) {
        guard let appDelegate = FavoritesService.appDelegate else {
            completion(false)
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(favoriteContact)
        appDelegate.saveContext()
        self.loadFavoritesData()
        completion(true)
    }
    
    /***
     * Convenience method fetches returns FavoritesContact from CoreData using a Contact
     */
    static func getFavoriteContact(_ contact: Contact) -> FavoritesContact? {
        let faveContact = self.allFavoritedContacts.filter { $0.phonebookID == Double(contact.phonebookID) }.first
        if let fave = faveContact {
            return fave
        }
        return nil
    }
    
    static func updateFavoritesStatus(_ contact: Contact) -> Bool {
        return self.allFavoritedContacts.filter { $0.phonebookID == Double(contact.phonebookID) }.first != nil
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
        // TODO: favContact.groupPosition = Double(favoritesGroupHash[groupTitle].count)
        appDelegate.saveContext()
        return favContact
    }
    
    /***
     * Convenience method to return Array of all FavoritesGroup titles
     */
    static func getAllFavoritesGroups() -> Array<String> {
        self.loadFavoritesData()
        return Array(self.favoritesGroupHash.keys)
    }
    
    /***
     * Convenience method to FavoritesGroup Title from index
     */
    static func getFavoritesGroupTitle(for index: Int) -> String? {
        return self.favoritesSectionHash[index]
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
    
    /***
     * Convenience method to return single FavoriteContact based on Section, when displaying in TableViews
     */
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
    
    static func moveContact(from source: IndexPath, to destination: IndexPath) {
        guard
            let favContact = FavoritesService.getFavoriteContact(with: source),
            let appDelegate = FavoritesService.appDelegate else { return }
//        let movedObject = self.fruits[sourceIndexPath.row]
        /*
         * Get source Group using indexPath.section
         * Remove favContact from that Group using indexPath.row
         * Get destination Group using indexPath.section
         * Insert favContact into new group using indexPath.row
         * Update favContact.groupName to be destination favGroup.title
         * Save context
         */
        var sourceGroup = self.getFavoritesGroup(for: source.section)
        var destinationGroup = self.getFavoritesGroup(for: destination.section)
        sourceGroup?.remove(at: source.row)
        destinationGroup?.insert(favContact, at: destination.row)
        favContact.groupName = self.favoritesSectionHash[destination.section]
        appDelegate.saveContext()
        self.loadFavoritesData()
        
        print("Check favContact GroupName: \(favContact.groupName) and destinationGroup contents")
//        fruits.remove(at: sourceIndexPath.row)
//        fruits.insert(movedObject, at: destinationIndexPath.row)
    }
}

private extension FavoritesService {
    static var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    static var searchService = ContactsSearchService()
    
    /***
     * Returns all FavoritesContacts from CoreData, unbucketed
     */
    static var allFavoritedContacts: Array<FavoritesContact> {
        return self.getAllFavorites()
    }
    
    /***
     * Dictionary intended to take a Section Int & return Group title string, which can key into the favoritesHash
     */
    static var favoritesSectionHash = Dictionary<Int,String>()
    
    /***
     * Dictionary intended to expedite retrieving FavoritesGroup by Title String
     */
    static var favoritesGroupHash = Dictionary<String,FavoritesGroup>()
    
    /***
     * Returns an Array of all FavoritesContacts loaded from CoreData
     */
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
    
    /***
     * Add favoriteContact into an existing FavoritesGroup, or create a new Group and add to that while updating favoritesGroupHash & favoritesSectionHash
     */
    static func bucketFavoritesContacts(with favContact: FavoritesContact) {
        if let favGroup = favoritesGroupHash[favContact.groupName!] {
            favGroup.favoritedContacts.append(favContact) // TODO: Append at index favContact.index
        } else {
            let favGroup = FavoritesGroup(with: favContact)
            favoritesGroupHash[favContact.groupName!] = favGroup
            self.favoritesSectionHash[self.favoritesGroupHash.count-1] = favContact.groupName!
        }
    }
}
