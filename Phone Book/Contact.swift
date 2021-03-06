//
//  Contact.swift
//  Phone Book
//
//  Created by Admin on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class Contact {
    
    var fullName: String
    var firstName: String
    var lastName: String
    var middleName: String
    var phonebookID: Int
    var jobTitle: String
    var department: String = ""
    var pagerNumber: String
    var displayPagerNumber: String
    var pagerEmail: String
    var emailAddress: String
    var primaryAddressLine1: String
    var primaryAddressLine2: String
    var primaryTelephone: String
    var displayPrimaryTelephone: String
    var primaryFax: String
    var displayPrimaryFax: String
    var cellphone: String
    var displayCellPhone: String
    var cellEmail: String
    var isDisabled: Int
    var isFavorited: Bool = false
    
    init(userDict: Dictionary<String,Any>)
    {
        self.fullName = userDict["pbFullname"] as? String ?? ""
        self.phonebookID = userDict["phonebookID"] as? Int ?? -1
        if let department = userDict["departmentName"] as? String {
            // Strip ", Department of" from departmentName
            let strippedText = department.components(separatedBy: ", Department of")
            if let text = strippedText.first, text.isEmpty == false {
                self.department = String(describing: text)
            }
        }
        self.jobTitle = userDict["jobTitle"] as? String ?? ""
        self.firstName = userDict["firstName"] as? String ?? ""
        self.lastName = userDict["lastName"] as? String ?? ""
        self.middleName = userDict["middleName"] as? String ?? ""
        self.pagerNumber = userDict["pagerNumber"] as? String ?? ""
        self.displayPagerNumber = userDict["displayPagerNumber"] as? String ?? ""
        self.pagerEmail = userDict["pagerEmail"] as? String ?? ""
        self.emailAddress = userDict["emailAddress"] as? String ?? ""
        self.primaryAddressLine1 = userDict["primaryAddressLine1"] as? String ?? ""
        self.primaryAddressLine2 = userDict["primaryAddressLine2"] as? String ?? ""
        self.primaryTelephone = userDict["primaryTelephone"] as? String ?? ""
        self.displayPrimaryTelephone = userDict["displayPrimaryTelephone"] as? String ?? ""
        self.primaryFax = userDict["primaryFax"] as? String ?? ""
        self.displayPrimaryFax = userDict["displayPrimaryFax"] as? String ?? ""
        self.cellphone = userDict["cellphone"] as? String ?? ""
        self.displayCellPhone = userDict["displayCellPhone"] as? String ?? ""
        self.cellEmail = userDict["cellEmail"] as? String ?? ""
        self.isDisabled = userDict["isDisabled"] as? Int ?? -1
        self.updateFavoritedStatus()
    }
    
    init(favoriteContact: FavoritesContact) {
        self.fullName = favoriteContact.fullName ?? ""
        self.phonebookID = Int(favoriteContact.phonebookID)
        self.department = favoriteContact.department ?? ""
        self.jobTitle = favoriteContact.jobTitle ?? ""
        self.firstName = favoriteContact.firstName ?? ""
        self.lastName = favoriteContact.lastName ?? ""
        self.middleName = favoriteContact.middleName ?? ""
        self.pagerNumber = favoriteContact.pagerNumber ?? ""
        self.displayPagerNumber = favoriteContact.displayPagerNumber ?? ""
        self.pagerEmail = favoriteContact.pagerEmail ?? ""
        self.emailAddress = favoriteContact.emailAddress ?? ""
        self.primaryAddressLine1 = favoriteContact.primaryAddressLine1 ?? ""
        self.primaryAddressLine2 = favoriteContact.primaryAddressLine2 ?? ""
        self.primaryTelephone = favoriteContact.primaryTelephone ?? ""
        self.displayPrimaryTelephone = favoriteContact.displayPrimaryTelephone ?? ""
        self.primaryFax = favoriteContact.primaryFax ?? ""
        self.displayPrimaryFax = favoriteContact.displayPrimaryFax
            ?? ""
        self.cellphone = favoriteContact.cellphone ?? ""
        self.displayCellPhone = favoriteContact.displayCellPhone ?? ""
        self.cellEmail = favoriteContact.cellEmail ?? ""
        self.isDisabled = Int(favoriteContact.isDisabled)
        self.isFavorited = true
    }
}

private extension Contact {
    func updateFavoritedStatus() {
        self.isFavorited = FavoritesService.updateFavoritedStatus(self)
    }
}
