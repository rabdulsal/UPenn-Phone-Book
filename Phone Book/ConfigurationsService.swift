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
    private (set) static var LatestAppVersion: String?
    static let LatestVersionKey   = "latestVerion"
    static let MandatoryUpdateKey = "mandatoryUpdate"
    
    static func checkLatestAppVersion(completion: @escaping (_ isUpdatable: Bool, _ updateRequired: Bool, _ errorMessage: String?)->Void) {
        ConfigurationsService.requestService.checkLatestAppVersion { (settings, errorMessage) in
            // TODO: Un-comment once done testing
//            if
//                let _settings = settings,
//                let latestVersion = _settings[ConfigurationsService.LatestVersionKey] as? String,
//                let mandatoryVersion = _settings[ConfigurationsService.MandatoryUpdateKey] as? String
//            {
//                ConfigurationsService.LatestAppVersion = latestVersion
//                let canUpdate = latestVersion.isVersionNewer(currentVersion: ConfigurationsService.CurrentPhonebookVersion)
//                let mustUpdate = mandatoryVersion.isVersionNewer(currentVersion: ConfigurationsService.CurrentPhonebookVersion)
//                completion(canUpdate,mustUpdate,nil)
//
//            } else if let message = errorMessage {
//                completion(false,false,message)
//            } else {
//                completion(false,false,"Cannot determine latest Phonebook version. Please try re-launching the App to see if an update is required.")
//            }
            
            // TODO: Erase once testing done
            completion(false,false,nil)
        }
    }
}
