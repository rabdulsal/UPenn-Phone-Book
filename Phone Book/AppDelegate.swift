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

enum TabSection : Int {
    case Search
    case Favorites
    case Account
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    enum ApplicationRuntimeState : Int {
        case BETA
        case DEBUG
        case RELEASE
    }
    
    private let skipUpdateKey = "skipUpdateKey"
    var window: UIWindow?
    var authToken: String?
    var loginService: LoginService?
    var loginDelegateVC: UIViewController?
    var applicationRunState : ApplicationRuntimeState {
        #if BETA
            return ApplicationRuntimeState.BETA
        #else
            return ApplicationRuntimeState.DEBUG
        #endif
    }
    var shouldAutoFill: Bool {
        guard let autoFill = self.loginService?.shouldAutoFill else { return false }
        return autoFill
    }
    var isLoggedIn: Bool {
        guard let isLoggedIn = self.loginService?.isLoggedIn else { return false }
        return isLoggedIn
    }
    var rootViewController : RootViewController? {
        return self.window?.rootViewController as? RootViewController
    }
    var didSkipThisUpdate : Bool {
        guard
            let versionSkipped = UserDefaults.standard.value(forKey: self.skipUpdateKey) as? String
            else { return false }
        let latestVersion = ConfigurationsService.LatestAppVersion
        return versionSkipped == latestVersion
    }
    
    var storyboard : UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
    var updateViewController: UIViewController {
        let updateVC = storyboard.instantiateViewController(withIdentifier: "UpdateViewVC")
        return updateVC
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set UPenn Deep Blue NavigationBar & white navbar text
        UINavigationBar.appearance().barTintColor = UIColor.upennDeepBlue
        UINavigationBar.appearance().tintColor = UIColor.white
        // Set White Status Bar
        UIApplication.shared.statusBarStyle = .lightContent
        // Set global font style to Helvetica
        UILabel.appearance().font = UIFont.helvetica(size: 15.0)
        // Set global SVProgress styles
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setForegroundColor(UIColor.upennMediumBlue)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMaximumDismissTimeInterval(3.0)
        
        // Configure Analytics
        AnalyticsService.configure()
        
        // Register for Timeout Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimout(notification:)), name: NSNotification.Name.init(TimerUIApplication.ApplicationDidTimeoutNotification), object: nil)
        
        // Configure main Window/RootViewController
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteContact")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func skipUpdate() {
        UserDefaults.standard.set(ConfigurationsService.LatestAppVersion, forKey: self.skipUpdateKey)
    }
    
    // MARK: - Sections
    
    func goToSection(_ section: TabSection) {
        self.rootViewController?.goToSection(section)
    }
    
    // MARK: - LoginService
    
    func setLoginDelegate(loginDelegate: LoginServiceDelegate) {
        self.loginService = LoginService(loginDelegate: loginDelegate)
        self.loginDelegateVC = loginDelegate as? UIViewController
    }
    
    func makeLoginRequest(email: String, password: String) {
        self.loginService?.makeLoginRequest(email: email, password: password)
    }
    
    func attemptSilentLogin() {
        self.loginService?.attemptSilentLogin()
    }
    
    func authenticationAutoFillCheck() {
        self.loginService?.authenticationAutoFillCheck()
    }
    
    func toggleShouldAutoFill(_ autoFill: Bool) {
        self.loginService?.toggleShouldAutoFill(autoFill)
    }
    
    var isFirstLogin: Bool { return self.loginService?.isFirstLogin ?? false }
    
    func setFirstLogin() {
        self.loginService?.setFirstLogin()
    }
    
    func cacheLoginCredentials(username: String, password: String) {
        self.loginService?.cacheLoginCredentials(username: username, password: password)
    }
    
    // MARK: - Timeout Notification
    // Callback for when the timeout was fired.
    func applicationDidTimout(notification: NSNotification) {
        self.rootViewController?.dismissAndPresentLogout()
    }
    
    func resetLogoutTimer() {
        TimerUIApplication.resetIdleTimer()
    }
    
    // MARK: - Logout
    
    func logout() {
        /*
         * 1. Turn off logout timer
         * 2. Logout
         * 3. Reload to Login flow via rootViewController
         */
        TimerUIApplication.invalidateActiveTimer()
        self.loginService?.logout()
        self.rootViewController?.resetToLogin()
    }
}
