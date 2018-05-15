//
//  ConfigurationsService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 5/14/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation

class ConfigurationsService {
    private static var requestService = NetworkRequestService()
    static var CurrentPhonebookVersion : String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    static let LatestVersionKey   = "latestVerion"
    static let MandatoryUpdateKey = "mandatoryUpdate"
    
    static func checkLatestAppVersion(completion: @escaping (_ isUpdatable: Bool, _ updateRequired: Bool, _ errorMessage: String?)->Void) {
        ConfigurationsService.requestService.checkLatestAppVersion { (settings, errorMessage) in
//            if
//                let _settings = settings,
//                let latestVersion = _settings[ConfigurationsService.LatestVersionKey] as? String,
//                let updateRequired = _settings[ConfigurationsService.MandatoryUpdateKey] as? Bool
//            {
//                let isUpdatable = ConfigurationsService.CurrentPhonebookVersion != latestVersion
//                completion(isUpdatable,updateRequired,nil)
//
//            } else if let message = errorMessage {
//                completion(false,false,message)
//            } else {
//                completion(false,false,"Sorry, we couldn't determine UPHS Phonebook's latest version. Please try re-launching the application.")
//            }
            
            // TODO: Erase once testing done
            completion(false,false,nil)
        }
    }
}
