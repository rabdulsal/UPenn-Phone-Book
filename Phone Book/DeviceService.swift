//
//  DeviceService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 11/28/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

class DeviceService {
    static func copyToClipboard(_ text: String, completion: ((_ copied: Bool)->Void)?=nil) {
        UIPasteboard.general.string = text
        let copied = UIPasteboard.general.string != nil
        if let _completion = completion {
            _completion(copied)
        }
    }
    
    static func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    static func openAsURL(_ urlString: String, completion: ((_ success: Bool)->Void)?=nil) {
        var success = false
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            success = true
        }
        if let _completion = completion {
            _completion(success)
        }
    }
}
