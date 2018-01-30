//
//  String+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/25/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation

extension String {
    /**
     Convenience var for removing whitespace at beginning and end of a String
    */
    var trim : String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    /**
     Convenience var for determining if a String is empty whitespace
     */
    var isBlankSpaceTrimmed : Bool {
        return !self.trim.isEmpty
    }
    
    /**
     Convenience variable for returning a localized string; primarily to be used for text visible to the user
    */
    var localize : String {
        return NSLocalizedString(self, comment: self)
    }
}
