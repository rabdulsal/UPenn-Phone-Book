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
    
    enum SegueIDs : String {
        case details = "ContactDetailsSegue"
        case login = "LoginSegue"
    }
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var loginService = LoginService()
    var contactsList = Array<Contact>()
    let reuseIdentifier = "ContactCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkAuthenticationForPresentation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = SegueIDs.init(rawValue: segue.identifier!) else { return }
        
        switch segueID {
            case .details:
                let contact = sender as! Contact
                let vc = segue.destination as! ContactDetailsViewController
                vc.contact = contact
            case .login:
                break
        }
    }
}

extension ContactsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.contactsList[indexPath.row]
        let profileID = contact.phonebookID
        
        // TODO: Make network request for contact profile using profileID
        
            // Push retrieved contact via segue
            self.performSegue(withIdentifier: SegueIDs.details.rawValue, sender: contact)
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
    
    func checkAuthenticationForPresentation() {
        
        if loginService.isLoggedIn {
            self.performSegue(withIdentifier: SegueIDs.login.rawValue, sender: nil)
        }
    }
}
