//
//  ContactGroupViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/22/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

enum ContactGroupContext : String {
    case groupText = "text"
    case groupEmail = "email"
}

class ContactGroupViewController : UIViewController {
    
    @IBOutlet weak var groupTableView: UITableView!
    
    fileprivate var groupContacts : [FavoritesContact] {
        return self.favoritesGroups.favoritedContacts
    }
    var contactService: ContactService!
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
        self.groupTableView.isEditing = false
        self.groupTableView.allowsMultipleSelection = true
        self.groupTableView.delegate = self
        self.groupTableView.dataSource = self
        self.groupTableView.tableFooterView = UIView()
        
        // NavBar Configs
        self.navigationItem.title = self.contactContext == .groupText ?
            "Text \(self.favoritesGroups.title)" :
            "Email \(self.favoritesGroups.title)"
        
        // ContactService
        self.contactService = ContactService(viewController: self, contacts: self.groupContacts, delegate: self)
    }
    
    // MARK: IBActions
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        self.dismiss()
    }
}

extension ContactGroupViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let contact = self.groupContacts[indexPath.row]
        cell?.accessoryType = .checkmark
        self.contactService.addToContactGroup(contact)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let contact = self.groupContacts[indexPath.row]
        cell?.accessoryType = .none
        self.contactService.removeFromContactGroup(contact)
    }
}

extension ContactGroupViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.groupContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! UITableViewCell
        let contact = self.groupContacts[indexPath.row]
        if self.contactService.reconcileContactSelectionState(contact: contact) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            cell.accessoryType = .none
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = contact.fullName
        return cell
    }
}

extension ContactGroupViewController : ContactServicable {
    func cannotEmailError(message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func cannotTextError(message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func cannotCallError(message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
}
