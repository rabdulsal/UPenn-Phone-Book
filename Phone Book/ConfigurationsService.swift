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
    static var PhoneBookBundleID : String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as! String
    }
    private (set) static var LatestAppVersion: String?
    static let LatestVersionKey   = "CurrentVersion"
    static let MandatoryUpdateKey = "MinimumVersion"
    
    static func checkLatestAppVersion(completion: @escaping (_ isUpdatable: Bool, _ updateRequired: Bool, _ errorMessage: String?)->Void) {
        ConfigurationsService.requestService.checkLatestAppVersion { (response) in
            if
                let settings = response.result.value as? Dictionary<String,Any>,
                let latestVersion = settings[ConfigurationsService.LatestVersionKey] as? String,
                let mandatoryVersion = settings[ConfigurationsService.MandatoryUpdateKey] as? String
            {
                ConfigurationsService.LatestAppVersion = latestVersion
                let canUpdate = latestVersion.isVersionNewer(currentVersion: ConfigurationsService.CurrentPhonebookVersion)
                let mustUpdate = mandatoryVersion.isVersionNewer(currentVersion: ConfigurationsService.CurrentPhonebookVersion)
                completion(canUpdate,mustUpdate,nil)

            } else if let message = response.result.error {
                completion(false,false,message.localizedDescription)
            } else {
                completion(false,false,"Cannot determine latest Phonebook version. Please try re-launching the App to see if an update is required.")
            }
        }
    }
}
