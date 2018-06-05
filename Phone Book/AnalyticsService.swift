//
//  AnalyticsService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 5/9/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import Firebase

class AnalyticsService {
    
    static func configure() {
        FirebaseApp.configure()
    }
    
    static func trackLoginEvent() {
        Analytics.logEvent(AnalyticsEventLogin, parameters: nil)
    }
    
    static func trackSearchEvent(_ searchText: String) {
        Analytics.logEvent("search_request_successful", parameters: ["searchQuery" : searchText])
    }
    
    static func trackFavoriteContact(_ contactName: String) {
        Analytics.logEvent("favorited_contact", parameters: ["favoritedContactName" : contactName])
    }
}
