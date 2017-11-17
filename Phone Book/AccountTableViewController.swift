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
    
    enum Sections : Int {
        case Settings
        
        static var count : Int {
            return Settings.rawValue+1
        }
    }
    
    enum SectionTitles : String {
        case Settings = "Settings"
    }
    
    override func viewDidLoad() {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _section = Sections(rawValue: section) else { return 0 }
        
        switch _section {
        case .Settings:
            return 2
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountSettingsCell
            return cell
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell") as! UITableViewCell
//            cell.textLabel?.text = "Logout"
//            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Logout User
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SectionTitles.Settings.rawValue
    }
}
