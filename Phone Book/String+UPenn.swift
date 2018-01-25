//
//  String+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/25/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation

extension String {
    var trim : String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    var isBlankSpaceTrimmed : Bool {
        return !self.trim.isEmpty
    }
}
