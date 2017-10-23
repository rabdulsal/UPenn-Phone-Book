//
//  ContactsListViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class ContactsListViewController : UIViewController {
    
    enum SegueIDs : String {
        case details = "ContactDetailsSegue"
        case login = "LoginSegue"
    }
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var searchService = ContactsSearchService()
    var contactsList = Array<Contact>()
    var searchController: UISearchController!
    let reuseIdentifier = "ContactCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkAuthenticationForPresentation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = SegueIDs.init(rawValue: segue.identifier!) else { return }
        
        switch segueID {
            case .details:
                guard let contact = sender as? Contact else { return }
                let vc = segue.destination as! ContactDetailsViewController
                vc.contact = contact
            case .login:
                break
        }
    }
}

// MARK: - UITableViewDelegate

extension ContactsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.contactsList[indexPath.row]
        let profileID = String(describing: contact.phonebookID)
        
        // TODO: Make network request for contact profile using profileID
        self.searchService.makeContactSearchRequest(with: profileID) { (contact, error) in

            // Push retrieved contact via segue
            if let e = error {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            } else {
                self.performSegue(withIdentifier: SegueIDs.details.rawValue, sender: contact)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ContactsListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: 'searchInProgress logic for real-time filtering of 'Favorites'
        return self.contactsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let contact = self.contactsList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ContactViewCell
        cell.configure(with: contact)
        return cell
    }
}

// MARK: - UISearchControllerDelegate

extension ContactsListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SVProgressHUD.show()
        self.searchService.makeContactsListSearchRequest(with: searchBar.text!) { (retrievedContacts, error) in
            SVProgressHUD.dismiss()
            searchBar.resignFirstResponder()
            if let e = error {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            } else {
                // TODO: Make logic for if retrievedContacts == 0 to show Alert
                if retrievedContacts.count == 0 {
                    SVProgressHUD.showError(withStatus: "No results returned.")
                    return
                }
                self.contactsList = retrievedContacts
                self.contactsTableView.reloadData()
            }
        }
    }
}

// MARK: - UISearchResultsUpdating

extension ContactsListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Filter results logic
    }
}

private extension ContactsListViewController {
    
    func setup() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        self.contactsTableView.tableHeaderView = self.searchController.searchBar
        self.contactsTableView.tableFooterView = UIView()
    }
    
    func checkAuthenticationForPresentation() {
        if !AuthenticationService.isAuthenticated {
            self.performSegue(withIdentifier: SegueIDs.login.rawValue, sender: nil)
        }
    }
}
