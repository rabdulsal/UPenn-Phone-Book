
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
typealias ErrorStringHandler = (_ errorString: String?)->Void

class FavoritesGroup {
    var title: String
    var favoritedContacts = Array<FavoritesContact>()
    
    init(with favorites: [FavoritesContact]) {
        self.title = favorites.first!.groupName!
        for favorite in favorites {
            self.favoritedContacts.append(favorite)
        }
    }
}

class FavoritesService {
    static let UpdateError = "Sorry, there was an error updating this record."
    static var favoritesGroupsCount : Int {
        return self.favoritesGroupHash.count
    }
    
    /**
     Convenience method to reload all FavoritesContact data in CoreData
     */
    static func loadFavoritesData() {
        self.favoritesSectionHash.removeAll()
        self.favoritesGroupHash.removeAll()
        self.reconcileFavoritesSectionIndexOrder()
    }
    
    /**
     Convenience method to add a Contact to a new Favorites Group. Method returns an error if the groupTitle is not unique.
     
    - parameters:
        - contact: The contact object to be added the Favorites Group
        - groupTitle: String representing the title of the New Favorites Group.
        - completion: Invoked upon successful/failed attempt to add to Favorites cache.
    */
    static func addNewFavorite(_ contact: Contact, groupTitle: String, completion: @escaping (ErrorStringHandler)) {
        // If groupTitle already exists, add to existing FavoritesGroup; make new FavoritesGroup if not
        guard let _ = self.favoritesGroupHash[groupTitle] else {
            self.addToFavorites(contact, groupTitle: groupTitle) { (favContact, errorStr) in
                self.updateFavoriteSuccessHandler(favContact, errorStr, completion: completion)
            }
            return
        }
        self.addFavoriteContactToExistingGroup(contact: contact, groupTitle: groupTitle, completion: completion)
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
    static func addFavoriteContactToExistingGroup(contact: Contact, groupTitle: String, completion: @escaping (ErrorStringHandler)) {
        self.addToFavorites(contact, groupTitle: groupTitle) { (favContact, errorString) in
            self.updateFavoriteSuccessHandler(favContact, errorString, completion: completion)
        }
    }
    
    /**
     Convenience method to removeFromFavorites using a Contact
     
    - parameters:
        - contact: Contact object to be removed from the Favorites cache.
        - completion: Invoked upon successful/failed attempt to remove from Favorites cache.
     */
    static func removeFromFavorites(contact: Contact, completion: (ErrorStringHandler)) {
        guard let appDelegate = self.appDelegate, let managedContext = self.managedContext else { return }
        if let favContact = self.getFavoriteContact(contact) {
            managedContext.delete(favContact)
            appDelegate.saveContext()
            self.loadFavoritesData()
            completion(nil)
        }
        completion(UpdateError)
    }
    
    /**
     Convenience method to removeFromFavorites using a FavoritesContact
     
     - parameters:
        - favoriteContact: FavoriteContact object to be removed from the Favorites cache.
        - completion: Invoked upon successful/failed attempt to remove from Favorites cache.
     */
    static func removeFromFavorites(favoriteContact: FavoritesContact, completion: (ErrorStringHandler)) {
        guard let appDelegate = self.appDelegate, let managedContext = self.managedContext else {
            completion(UpdateError)
            return
        }
        managedContext.delete(favoriteContact)
        appDelegate.saveContext()
        self.loadFavoritesData()
        completion(nil)
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
        favContact.groupSectionIndex        = self.generateFavoritesGroupSectionIndex(groupTitle: groupTitle)
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
     Convenience method to update FavoritesGroup title
     - parameters:
        - oldTitle: Old FavoritesGroup title to be changed
        - newTitle: New FavoritesGroup title to be updated
     */
    static func updateFavoritesGroupTitle(from oldTitle: String, to newTitle: String, completion: @escaping (ErrorStringHandler)) {
        // If newTitle already exists for another group, return error
        guard let _ = favoritesGroupHash[newTitle] else {
            // Get Favorites Group using oldTitle & copy
            guard
                let favorites = favoritesGroupHash[oldTitle]?.favoritedContacts,
                let appDelegate = self.appDelegate else { return }
            // Loop through all favContacts, update the groupNames & save
            for favContact in favorites {
                favContact.groupName = newTitle
            }
            appDelegate.saveContext()
            // Reload FavoritesData
            self.loadFavoritesData()
            completion(nil)
            return
        }
        completion("Please use a unique title for updating your Favorites Group.")
    }
    
    /**
     Convenience method to return Array of FavoritedContacts based on group title
     
     - parameter groupTitle: Title of group to return FavoritesContacts
    */
    static func getFavoritesContacts(with groupTitle: String) -> Array<FavoritesContact> {
        // If newTitle already exists for another group, return error
        guard let favsGroup = favoritesGroupHash[groupTitle] else {
            return Array<FavoritesContact>()
        }
        return favsGroup.favoritedContacts
    }
    
    /**
     Convenience method to return Array of FavoritedContacts based on Section, when displaying in TableViews
     */
    static func getFavoritesContacts(for section: Int) -> Array<FavoritesContact>? {
        guard let favsGroup = self.getFavoritesGroup(for: section) else { return nil }
        return favsGroup.favoritedContacts
    }
    
    /**
     Convenience method to return FavoritesGroup based on Section, when displaying in TableViews
     */
    static func getFavoritesGroup(for section: Int) -> FavoritesGroup? {
        if
            let groupTitle = self.favoritesSectionHash[section],
            let favsGroup = self.favoritesGroupHash[groupTitle] {
            return favsGroup
        }
        return nil
    }
    
    /**
     Convenience method to return single FavoriteContact based on Section, when displaying in TableViews
     
    - parameter indexPath: IndexPath object providing section & row from which to fetch/return FavoriteContact
     */
    static func getFavoriteContact(with indexPath: IndexPath) -> FavoritesContact? {
        guard let favContacts = self.getFavoritesContacts(for: indexPath.section) else { return nil }
        return favContacts[indexPath.row]
    }
    
    /**
     Convenience method to return array of FavoritesContacts that have cellPhone number data
     
     - parameter section: Int representing tableView section to use for fetching specific FavoritesContact
     */
    static func getTextableFavorites(for section: Int) -> Array<FavoritesContact>? {
        guard let favorites = self.getFavoritesContacts(for: section) else { return nil }
        var textableFavs = [FavoritesContact]()
        for contact in favorites {
            if let cell = contact.cellphone, !cell.isEmpty {
                textableFavs.append(contact)
            }
        }
        return textableFavs
    }
    
    /**
     Convenience method to return array of FavoritesContacts that have emailAddress data
     
     - parameter section: Int representing tableView section to use for fetching specific FavoritesContact
     */
    static func getEmailableFavorites(for section: Int) -> Array<FavoritesContact>? {
        guard let favorites = self.getFavoritesContacts(for: section) else { return nil }
        var emailableFavs = [FavoritesContact]()
        for contact in favorites {
            if let email = contact.emailAddress, !email.isEmpty {
                emailableFavs.append(contact)
            }
        }
        return emailableFavs
    }
    
    /**
     Convenience method to return Count for each FavoritesGroup when displaying in TableViews by Section
     */
    static func getFavoritesContactsCount(for section: Int) -> Int {
        guard let favContacts = self.getFavoritesContacts(for: section) else { return 0 }
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
            let favContact = self.getFavoriteContact(with: source),
            let appDelegate = self.appDelegate else { return }
        /*
         Get source Group using indexPath.section
         Remove favContact from that Group using indexPath.row
         Get destination Group using indexPath.section
         Insert favContact into new group using indexPath.row
         Update favContact.groupName to be destination favGroup.title
         Save context
         */
        var sourceGroup = self.getFavoritesContacts(for: source.section)
        var destinationGroup = self.getFavoritesContacts(for: destination.section)
        if sourceGroup! == destinationGroup! {
            destinationGroup?.remove(at: source.row)
        } else {
            sourceGroup?.remove(at: source.row)
        }
        destinationGroup?.insert(favContact, at: destination.row)
        favContact.groupName = self.favoritesSectionHash[destination.section]
        favContact.groupSectionIndex = Double(destination.section)
        /*
         * Prevent contacts' groupPositions from falling out of sync:
         * Loop through all the contacts in the destination favoriteContacts and manually set their groupPosition in order
        */
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
     
     - parameter groupTitle: Title of the FavoritesGroup to create
     */
    static func generateFavoritesGroupPosition(groupTitle: String) -> Double {
        guard
            let favorites = favoritesGroupHash[groupTitle]?.favoritedContacts else { return 0.0 }
        return Double(favorites.count)
    }
    
    /**
     Create a FavoritesContact groupPositionSection for FavoritesGroup using a groupTitle
     
     - parameter groupTitle: Title of the FavoritesGroup used to derive a section index
     */
    static func generateFavoritesGroupSectionIndex(groupTitle: String) -> Double {
        for (section, title) in self.favoritesSectionHash {
            if title == groupTitle {
                return Double(section)
            }
        }
        return Double(self.favoritesSectionHash.count)
    }
    
    /**
     Method takes a FavoritesContact parameter and returns a SucceHandler closure
     
     - parameters:
     - favoriteContact: Optional FavoriteContact added to the Favorites cache.
     - errorString: Optional error string returned if failed to add FavoritesContact
     - completion: Invoked upon successful/failed attempt to remove from Favorites cache.
    */
    static func updateFavoriteSuccessHandler(_ contact: FavoritesContact?, _ errorString: String?, completion: @escaping (ErrorStringHandler)) {
        if let error = errorString {
            completion(error)
        }
        completion(nil)
    }
    
    /**
     Convenience method to ensure the incremental order of individual FavoritesContacts' groupSectionIndicies
     */
    static func reconcileFavoritesSectionIndexOrder() {
        /*
         1. Fetch all FavoritesContacts and sorts them ascending
         2. Loop through each favoritesContact in order while keeping reference of section names & indicies to trigger updates
         3. As section names change, update the running section name and incremement the running section index
         4. Check the current FavoritesContact's groupSectionIndex against the running section index, and update the favorite's groupSectionIndex accordingly
         5. Pass off the FavoritesContact to update the SectionHash and GroupHash
        */
        guard let appDelegate = self.appDelegate else { return }
        let allFavorites = self.getAllFavorites().sorted { (fav1, fav2) -> Bool in
            return fav1.groupSectionIndex < fav2.groupSectionIndex
        }
        var sectionIdxCache = -1
        var sectionNameCache = ""
        for idx in 0..<allFavorites.count {
            let favorite = allFavorites[idx]
            let currentSection = Int(favorite.groupSectionIndex)
            let currentName = favorite.groupName!
            if currentName != sectionNameCache {
                sectionNameCache = currentName
                sectionIdxCache+=1
            }
            if currentSection != sectionIdxCache {
                favorite.groupSectionIndex = Double(sectionIdxCache)
                appDelegate.saveContext()
            }
            self.bucketFavoritesContacts(with: favorite)
        }
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
            let favGroup = FavoritesGroup(with: [favContact])
            self.favoritesSectionHash[Int(favContact.groupSectionIndex)] = favContact.groupName!
            self.favoritesGroupHash[favContact.groupName!] = favGroup
        }
    }
}
