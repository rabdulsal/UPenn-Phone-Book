//
//  AppDelegate.swift
//  Phone Book
//
//  Created by Admin on 10/11/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SVProgressHUD

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    var authToken: String?
    var users = Array<Contact>()
    var tabBarController : UITabBarController? {
        return self.window?.rootViewController as? UITabBarController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor.upennDarkBlue
        UINavigationBar.appearance().tintColor = UIColor.white
        UILabel.appearance().font = UIFont.init(name: "Helvetica Neue", size: 15.0)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setForegroundColor(UIColor.upennMediumBlue)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMaximumDismissTimeInterval(2.0)
        
        self.tabBarController?.delegate = self
        
        // Register for Timeout Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimout(notification:)), name: NSNotification.Name.init(TimerUIApplication.ApplicationDidTimeoutNotification), object: nil)
        
        // Trigger Auto-logout Timer
        TimerUIApplication.resetIdleTimer()
        
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
        self.saveContext()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "FavoriteContact")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func logout() {
        /*
         * 1. Go To Search Screen
         * 2. Reload Contact view
         * 3. Launch LoginView
         */
        TimerUIApplication.invalidateActiveTimer()
        self.tabBarController?.selectedIndex = 0
        if let navVC = self.tabBarController?.selectedViewController as? UINavigationController, let contactsVC = navVC.childViewControllers.first as? ContactsListViewController {
            contactsVC.reloadView()
            contactsVC.showLoginView()
        }
    }
}

// MARK: - UITabBarViewController

extension AppDelegate : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // Clear out view if ContactsListViewController
        if let contactsVC = viewController.childViewControllers.first as? ContactsListViewController {
            contactsVC.reloadView()
        }
    }
    
    // Callback for when the timeout was fired.
    func applicationDidTimout(notification: NSNotification) {
        // Check if a viewController is presented, if not, show Auto-logout alert
        guard let navVC = self.tabBarController?.presentedViewController as? UINavigationController else {
            self.showLogoutAlert()
            return
        }
        
        // Check if the LoginViewController is presented, if not, show Auto-logout alert
        guard let _ = navVC.childViewControllers.first as? LoginViewController else {
            // Dismiss whatever presentedVC is showing, then display LogoutAlert
            navVC.dismiss(animated: true, completion: {
                self.showLogoutAlert()
            })
            return
        }
    }
    
    func showLogoutAlert() {
        let alertController = UIAlertController(title: "You've Been Logged-out", message: "For security purposes you've been automatically logged-out due to inactivity. Please log back in.", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Login", style: .cancel, handler: {
            alert -> Void in
            self.logout()
        })
        alertController.addAction(logoutAction)
        self.tabBarController?.present(alertController, animated: true, completion: nil)
    }
}

