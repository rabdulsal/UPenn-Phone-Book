//
//  ContactGroupViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/22/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

enum ContactGroupContext : String {
    case groupText = "text"
    case groupEmail = "email"
}

class ContactGroupViewController : UIViewController {
    
    @IBOutlet weak var groupTableView: UITableView!
    
    fileprivate var groupContacts : [FavoritesContact] {
        return self.favoritesGroups.favoritedContacts
    }
    var favoritesGroups: FavoritesGroup!
    var contactContext: ContactGroupContext = .groupText
    let identifier = "ContactGroupID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func setup() {
        super.setup()
        
        // Configure TableView
        self.groupTableView.delegate = self
        self.groupTableView.dataSource = self
        self.groupTableView.tableFooterView = UIView()
        
        // NavBar Configs
        self.navigationItem.title = self.contactContext == .groupText ?
            "Text \(self.favoritesGroups.title)" :
            "Email \(self.favoritesGroups.title)"
        self.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    // MARK: IBActions
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        self.dismiss()
    }
}

extension ContactGroupViewController : UITableViewDelegate {
    
}

extension ContactGroupViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.groupContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! UITableViewCell
        let contact = self.groupContacts[indexPath.row]
        cell.textLabel?.text = contact.fullName
        return cell
    }
    
    
}
