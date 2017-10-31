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
        case favorites = "FavoritesGroupsSegue"
    }
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var searchService = ContactsSearchService()
    var contactsList = Array<Contact>()
    var searchController: UISearchController!
    let reuseIdentifier = "ContactCell"
    let helpText = "Using 'Tom Smith' as an example:\nIn the SearchBar, to search by first name then last name, type 'Tom Smith'\nTo search by last name then first name, type 'Smith, Tom.'\nYou can also search with partial spelling like 'T Smith' or 'Sm, T'."
    
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
                let navVC = segue.destination as! UINavigationController
                navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            case .favorites:
                guard let contact = sender as? Contact else { return }
                let navVC = segue.destination as! UINavigationController
                navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
                let favsListVC = navVC.viewControllers.first as! FavoritesGroupsListViewController
                favsListVC.contact = contact
        }
    }
    
    override func setup() {
        super.setup()
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        self.contactsTableView.tableHeaderView = self.searchController.searchBar
        self.contactsTableView.tableFooterView = UIView()
        self.tabBarController?.delegate = self
    }
    
    // IBActions
    @IBAction func helpPressed(_ sender: Any) {
        let alertCtrl = UIAlertController(title: "Search Help", message: self.helpText, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertCtrl, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension ContactsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.contactsList[indexPath.row]
        let profileID = String(describing: contact.phonebookID)
        
        self.searchService.makeContactSearchRequest(with: profileID) { (contact, error) in

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
        cell.configure(with: contact, delegate: self, sectionIndex: indexPath)
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.reloadView()
    }
}

// MARK: - UITabBarViewController

extension ContactsListViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.childViewControllers.first! is FavoritesViewController {
            self.reloadView()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension ContactsListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Filter results logic
    }
}

// MARK: - ToggleFavoritesDelegate

extension ContactsListViewController : ToggleFavoritesDelegate {
    func addToFavorites(for indexPath: IndexPath) {
        /*
         * 1. Get reference to FavoritesGroupsListVC
         * 2. Set self as delegate
         * 3. Show FavoritesGroupsListVC
         */
        let contact = self.contactsList[indexPath.row]
        self.performSegue(withIdentifier: SegueIDs.favorites.rawValue, sender: contact)
    }
    
    func removeFromFavorites(for indexPath: IndexPath) {
        /*
         * 1. Use IndexPath Section and Row to get FavoritesContact
         * 2. Make RemoveFromFavorites Service call
         * 3. Within completion, get cell using indexPath and toggle the favoritesButton passing 'false'
         */
        if let favContact = FavoritesService.getFavoriteContact(with: indexPath) {
            FavoritesService.removeFromFavorites(favoriteContact: favContact) { (success) in
                self.contactsTableView.reloadData()
            }
        }
    }
}

private extension ContactsListViewController {
    
    func checkAuthenticationForPresentation() {
        if !AuthenticationService.isAuthenticated {
            self.performSegue(withIdentifier: SegueIDs.login.rawValue, sender: nil)
        }
    }
    
    func reloadView() {
        self.contactsList.removeAll()
        self.contactsTableView.reloadData()
    }
}
