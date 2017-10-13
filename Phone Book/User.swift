//
//  User.swift
//  Phone Book
//
//  Created by Admin on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class User {
    
    var firstName: String
    var lastName: String
    var jobTitle: String
    var officeAddress: String
    var cellPhone: String
    var officePhone: String
    
    init(
        fName: String,
        lName: String,
        jobTitle: String,
        address: String,
        cellNum: String,
        officeNum: String)
    {
        self.firstName = fName
        self.lastName = lName
        self.jobTitle = jobTitle
        self.officeAddress = address
        self.cellPhone = cellNum
        self.officePhone = officeNum
    }
}
