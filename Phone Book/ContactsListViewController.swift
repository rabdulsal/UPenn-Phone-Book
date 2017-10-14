//
//  ContactsListViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class ContactsListViewController : UIViewController {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var contactsList = Array<Contact>()
    let reuseIdentifier = "ContactCell"
    let detailsSegue = "ContactDetailsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contact = sender as! Contact
        let vc = segue.destination as! ContactDetailsViewController
        vc.contact = contact
    }
}

extension ContactsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.contactsList[indexPath.row]
        let profileID = contact.phonebookID
        
        // TODO: Make network request for contact profile using profileID
        
            // Push retrieved contact via segue
            self.performSegue(withIdentifier: self.detailsSegue, sender: contact)
    }
}

extension ContactsListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let contact = self.contactsList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ContactViewCell
        
        cell.textLabel?.text = contact.fullName
        return cell
    }
}

private extension ContactsListViewController {
    
}
