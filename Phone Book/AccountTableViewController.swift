//
//  AccountTableViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 11/16/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class AccountTableViewController : UITableViewController {
    
    private enum Sections : Int {
        case Settings
        
        static var count : Int {
            return Settings.rawValue+1
        }
        
        enum Rows : Int {
            case Timeout
            case Logout
            case AutoLogin
        }
    }
    
    private enum SectionTitles : String {
        case Settings = "Settings"
    }
    
    private enum Identifiers : String {
        case Timeout = "TimeoutCell"
        case Logout = "LogoutCell"
        case AutoLogin = "AccountCell"
    }
    
    var appDelegate : AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    override func viewDidLoad() {
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func setup() {
        super.setup()
        self.tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _section = Sections(rawValue: section) else { return 0 }
        
        switch _section {
        case .Settings:
            return 3
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Sections(rawValue: indexPath.section), let row = Sections.Rows(rawValue: indexPath.row) else { return UITableViewCell() }
        
        switch section {
        case .Settings:
            switch row {
            case .Timeout:
                let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Timeout.rawValue) as! AutoLogoutCell
                return cell
            case .AutoLogin:
                let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.AutoLogin.rawValue) as! AccountSettingsCell
                cell.configure()
                return cell
            case .Logout:
                let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Logout.rawValue) as! UITableViewCell
                cell.textLabel?.text = "Logout"
                return cell
            default:
                return UITableViewCell()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections(rawValue: indexPath.section), let row = Sections.Rows(rawValue: indexPath.row) else { return }
        // Logout User if Logout Cell pressed
        switch section {
        case .Settings:
            switch row {
            case .Logout:
                guard let appDelegate = self.appDelegate else { return }
                appDelegate.logout()
            default: return
            }
//        default: return Un-comment if more Sections added
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SectionTitles.Settings.rawValue
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

