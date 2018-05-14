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
    static var currentPhoneBookVersion : String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    static func checkLatestAppVersion(completion: @escaping (_ isUpdatable: Bool, _ updateRequired: Bool, _ errorMessage: String?)->Void) {
        ConfigurationsService.requestService.checkLatestAppVersion { (settings, errorMessage) in
            if
                let _settings = settings,
                let latestVersion = _settings[""] as? String,
                let updateRequired = _settings[""] as? Bool
            {
                let isUpdatable = ConfigurationsService.currentPhoneBookVersion == latestVersion
                completion(isUpdatable,updateRequired,nil)
                
            } else if let message = errorMessage {
                completion(false,false,message)
            }
        }
    }
}
