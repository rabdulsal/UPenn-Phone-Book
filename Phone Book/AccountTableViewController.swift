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
        
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountSettingsCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SectionTitles.Settings.rawValue
    }
}
