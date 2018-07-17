//
//  RootViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 6/6/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class RootViewController : UIViewController {
    
    var appDelegate : AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var tabController: UITabBarController?
    
    fileprivate var checkedForVersion = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkAppVersionForLaunch()
    }
    
    func resetToLogin() {
        self.tabController?.selectedIndex = 0
        if
            let navVC = self.tabController?.selectedViewController as? UINavigationController,
            let contactsVC = navVC.childViewControllers.first as? ContactsListViewController,
            let _ = contactsVC.view
        {
            self.presentLoginViewController()
            contactsVC.reloadView()
        }
    }
    
    func dismissAndPresentLogout() {
        // Check if a viewController is presented, if not, show Auto-logout alert
        guard let presentedVC = self.presentedViewController else {
            self.showLogoutAlert()
            return
        }
        
        // Check if the LoginViewController is presented, if not, show Auto-logout alert
        guard let _ = presentedVC as? LoginViewController else {
            self.dismiss(animated: true) {
                self.showLogoutAlert()
            }
            return
        }
    }
    
    func goToSection(_ section: TabSection) {
        switch section {
        case .Search:
            break
        case .Favorites:
            self.tabController?.selectedIndex = 1
            if
                let navVC = self.tabController?.selectedViewController as? UINavigationController,
                let favoritesVC = navVC.childViewControllers.first as? FavoritesViewController,
                let _ = favoritesVC.view {
                favoritesVC.reloadView()
            }
        case .Account:
            break
        }
    }
}

// MARK: - UITablBarControllerDelegate

extension RootViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let contactsVC = viewController.childViewControllers.first as? ContactsListViewController, let _ = contactsVC.view {
            if let delegate = self.appDelegate, !delegate.isLoggedIn {
                delegate.logout()
            } else {
                contactsVC.reloadView()
            }
            return
        }
        
        if let favsVC = viewController.childViewControllers.first as? FavoritesViewController, let _ = favsVC.view {
            favsVC.reloadView()
            return
        }
        
        // If clicking Accounts Tab, check if logged-out, if so, present login
        
        if let accountsVC = viewController.childViewControllers.first as? AccountTableViewController, let _ = accountsVC.view {
            if let delegate = self.appDelegate, !delegate.isLoggedIn {
                delegate.logout()
            }
        }
    }
}

// MARK: - Private

fileprivate extension RootViewController {
    
    var loginNavController: UINavigationController {
        let loginVC = self.appDelegate!.storyboard.instantiateViewController(withIdentifier: "LoginNav") as! UINavigationController
        return loginVC
    }
    
    var logoutAlertController : UIAlertController {
        let alertController = UIAlertController(title: "You've Been Logged-out", message: "For security purposes you've been automatically logged-out due to inactivity. Please log back in.", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Login", style: .cancel, handler: {
            alert -> Void in
            if let delegate = self.appDelegate { delegate.logout() }
        })
        alertController.addAction(logoutAction)
        return alertController
    }
    
    var optionalUpdateAlert : UIAlertController {
        let alertCtrl = UIAlertController(
            title: "App Update Available",
            message: "Version \(ConfigurationsService.LatestAppVersion) of the UPHS Phonebook App is available. If you want to update, press 'Get Update' and follow the instructions.",
            preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(
            title: "Get Update",
            style: .cancel,
            handler: nil))
        alertCtrl.addAction(UIAlertAction(
            title: "Skip Update",
            style: .default,
            handler: { (action) in
                self.appDelegate?.skipUpdate()
                self.showTabMainController()
        }))
        return alertCtrl
    }
    
    var mandatoryUpdateAlert : UIAlertController {
        let alertCtrl = UIAlertController(
            title: "App Update Available (MANDATORY)",
            message: "To continue using the UPHS Phonebook App, you MUST update to version \(ConfigurationsService.LatestAppVersion). Press 'Get Update' and follow the instructions.",
            preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(
            title: "Get Update",
            style: .cancel,
            handler: nil))
        return alertCtrl
    }
    
    func makeParentViewController(_ viewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    func swapParentViewController(fromVC: UIViewController, toVC: UIViewController) {
        addChildViewController(toVC)
        toVC.view.frame = view.bounds
        view.addSubview(toVC.view)
        toVC.didMove(toParentViewController: self)
        fromVC.willMove(toParentViewController: nil)
        fromVC.view.removeFromSuperview()
        fromVC.removeFromParentViewController()
    }
    
    var updateViewController: UIViewController {
        return self.appDelegate!.storyboard.instantiateViewController(withIdentifier: "UpdateViewVC")
    }
    
    func checkAppVersionForLaunch() {
        if !self.checkedForVersion {
            ConfigurationsService.checkLatestAppVersion { (isUpdatable, updateRequired, errorMessage) in
                self.checkedForVersion = true
                // If errorMessage show it
                if let message = errorMessage {
                    SVProgressHUD.showError(withStatus: message)
                    self.showTabMainController()
                    return
                }
                // If updateRequired show mandatory alert
                if updateRequired {
                    self.showUpdateViewController()
                    self.present(self.mandatoryUpdateAlert, animated: true, completion: nil)
                    return
                }
                // If isUpdatable show optional update alert
                if
                    let skippedUpdate = self.appDelegate?.didSkipThisUpdate,
                    isUpdatable && !skippedUpdate {
                    self.showUpdateViewController()
                    self.present(self.optionalUpdateAlert, animated: true, completion: nil)
                    return
                }
                self.showTabMainController()
            }
        }
    }
    
    func showTabMainController() {
        self.tabController = self.appDelegate?.storyboard.instantiateViewController(withIdentifier: "TabBarVC") as? UITabBarController
        self.tabController?.delegate = self
        self.makeParentViewController(self.tabController!)
        self.appDelegate?.logout()
    }
    
    func presentLoginViewController() {
        self.present(self.loginNavController, animated: true, completion: nil)
    }
    
    func showUpdateViewController() {
        self.makeParentViewController(self.updateViewController)
    }
    
    func showLogoutAlert() {
        self.present(self.logoutAlertController, animated: true, completion: nil)
    }
}


