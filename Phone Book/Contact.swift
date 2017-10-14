//
//  User.swift
//  Phone Book
//
//  Created by Admin on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class Contact {
    
    var fullName: String
    var phonebookID: Int
    var jobTitle: String
    var department: String
    
    /*
    var cellPhone: String
    var officePhone: String
    */
    
    init(userDict: Dictionary<String,Any>)
    {
        self.fullName = userDict["pbFullname"] as? String ?? ""
        self.phonebookID = userDict["phonebookID"] as? Int ?? -1
        self.department = userDict["departmentName"] as? String ?? ""
        self.jobTitle = userDict["jobTitle"] as? String ?? ""
    }
}
