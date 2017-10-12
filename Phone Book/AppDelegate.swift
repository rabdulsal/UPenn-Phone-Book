//
//  AppDelegate.swift
//  Phone Book
//
//  Created by Admin on 10/11/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let email = "AbdulSaR"
        let password = "R@shad1980"
        let authenticationURI = "http://uphsnettest2012.uphs.upenn.edu/oath/token"
        let phonebookProfileURI = "api/phonebook/search/{searchString}"
        
        guard let url = URL(string: authenticationURI) else {
            return false
        }
        
        let parameters: Parameters = [
            // Must be form: grant_type=password&username=yourADusername&password=yourADpassword
            "grant_type" : "password",
            "username" : email,
            "password" : password
        ]
        
        let request = Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
        request.responseString { (response) in
            print("Success: \(response.result.isSuccess)")
            print("Response String: \(response.result.value)")
            
            if let httpError = response.result.error {
                print("Error:", httpError.localizedDescription)
            } else {
                let statusCode = (response.response?.statusCode)!
                print("Status code:", statusCode)
            }
        }
        
        /*
 
         
        */
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

