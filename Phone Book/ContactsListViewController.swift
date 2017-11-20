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

protocol FavoritesUpdatable : AddToFavoritesDelegate, RemoveFromFavoritesDelegate { }

protocol AddToFavoritesDelegate {
    func successfullyAddedContactToFavorites()
}

protocol RemoveFromFavoritesDelegate {
    func successfullyRemovedContactFromFavorites()
}

class ContactsListViewController : UIViewController {
    
    enum SegueIDs : String {
        case details = "ContactDetailsSegue"
        case login = "LoginSegue"
        case favorites = "FavoritesGroupsSegue"
    }
    
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var noContactsView: UIView!
    @IBOutlet weak var noContactsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noContactsLabel: NoDataInstructionsLabel!
    
    var loginService: LoginService!
    var searchService = ContactsSearchService()
    var contactsList: Array<Contact>! {
        didSet {
            self.toggleNoContactsView(show: self.contactsList.count == 0)
        }
    }
    var searchController: UISearchController!
    let reuseIdentifier = "ContactCell"
    var favIndexPath: IndexPath?
    let helpText = "Using 'Tom Smith' as an example:\nIn the SearchBar, to search by first name then last name, type 'Tom Smith'\nTo search by last name then first name, type 'Smith, Tom.'\nYou can also search with partial spelling like 'T Smith' or 'Sm, T'."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contactsTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = SegueIDs.init(rawValue: segue.identifier!) else { return }
        
        switch segueID {
            case .details:
                guard let contact = sender as? Contact else { return }
                let vc = segue.destination as! ContactDetailsViewController
                vc.contact = contact
                vc.favoritesDelegate = self
            case .login:
                let navVC = segue.destination as! UINavigationController
                navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            case .favorites:
                guard let contact = sender as? Contact else { return }
                let navVC = segue.destination as! UINavigationController
                navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
                let favsListVC = navVC.viewControllers.first as! FavoritesGroupsListViewController
                favsListVC.contact = contact
                favsListVC.addFavoritesDelegate = self
        }
    }
    
    override func setup() {
        super.setup()
        self.contactsList = [Contact]()
        
        // SearchController configs
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        // TableView configs
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        self.contactsTableView.tableHeaderView = self.searchController.searchBar
        self.contactsTableView.tableFooterView = UIView()
        
        // Miscellaneous configs
        self.loginService = LoginService(loginDelegate: self)
        self.noContactsLabel.setFontHeight(size: 20.0)
        self.noContactsView.backgroundColor = UIColor.upennLightGray
        self.checkAuthenticationForPresentation()
    }
    
    // IBActions
    @IBAction func helpPressed(_ sender: Any) {
        let alertCtrl = UIAlertController(title: "Search Help", message: self.helpText, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertCtrl, animated: true, completion: nil)
    }
    
    // Public
    func reloadView() {
        self.navigationController?.popToRootViewController(animated: false)
        self.searchController.isActive = false
        self.reloadTableView()
    }
    
    func showLoginView() {
        self.performSegue(withIdentifier: SegueIDs.login.rawValue, sender: nil)
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
                self.favIndexPath = indexPath
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

// MARK: - LoginService Delegate

extension ContactsListViewController : LoginServiceDelegate {
    
    func didSuccessfullyLoginUser() {
        SVProgressHUD.showSuccess(withStatus: "You are logged in!")
    }
    
    func didReturnAutoFillCredentials(username: String, password: String) { }
    
    func didFailToLoginUser(errorStr: String) {
        SVProgressHUD.showError(withStatus: errorStr)
    }
}

// MARK: - UISearchControllerDelegate

extension ContactsListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SVProgressHUD.show()
        self.searchService.makeContactsListSearchRequest(with: searchBar.text!) { (retrievedContacts, error) in
            SVProgressHUD.dismiss()
            searchBar.resignFirstResponder()
            self.searchController.isActive = false
            if let e = error {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            } else {
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
        self.reloadTableView()
    }
}

// MARK: - UISearchResultsUpdating

extension ContactsListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.toggleNoContactsView(show: !self.searchController.isActive && self.contactsList.count == 0, delay: true)
    }
}

// MARK: - ToggleFavoritesDelegate

extension ContactsListViewController : ContactFavoritingDelegate {
    func addToFavorites(for indexPath: IndexPath) {
        let contact = self.contactsList[indexPath.row]
        self.favIndexPath = indexPath
        self.performSegue(withIdentifier: SegueIDs.favorites.rawValue, sender: contact)
    }
    
    func removeFromFavorites(for indexPath: IndexPath) {
        let contact = self.contactsList[indexPath.row]
        self.favIndexPath = indexPath
        if let favContact = FavoritesService.getFavoriteContact(contact) {
            FavoritesService.removeFromFavorites(favoriteContact: favContact) { (success) in
                self.updateFavoritesState(favorited: false)
            }
        }
    }
}

// MARK: - FavoritesUpdatable
extension ContactsListViewController : FavoritesUpdatable {
    func successfullyAddedContactToFavorites() {
        self.updateFavoritesState(favorited: true)
    }
    
    func successfullyRemovedContactFromFavorites() {
        self.updateFavoritesState(favorited: false)
    }
}

// MARK: - Private
private extension ContactsListViewController {
    
    func checkAuthenticationForPresentation() {
        // TODO: Update checking to use AppDelegate
        if self.loginService.shouldAutoLogin {
            self.loginService.attemptSilentLogin()
        } else {
            self.showLoginView()
        }
    }
    
    func updateFavoritesState(favorited: Bool) {
        if let idxPth = self.favIndexPath {
            let contact = self.contactsList[idxPth.row]
            contact.isFavorited = favorited
            self.favIndexPath = nil
            self.contactsTableView.reloadData()
        }
    }
    
    func reloadTableView() {
        self.contactsList.removeAll()
        self.contactsTableView.reloadData()
        let heightOffsetAdjustment = 0.0 - self.contactsTableView.contentOffset.y
        self.contactsTableView.setContentOffset(CGPoint.init(x: 0.0, y: 0.0), animated: true)
    }
    
    func toggleNoContactsView(show: Bool, delay: Bool=false) {
        if show {
            self.noContactsViewHeight.constant = 100
            if delay {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
                    self.noContactsView.isHidden = false
                })
            } else {
                self.noContactsView.isHidden = false
            }
            self.noContactsLabel.text = "Search for a Penn Medicine employee by last name or first name."
        } else {
            self.noContactsView.isHidden = true
            self.noContactsViewHeight.constant = 0
            self.noContactsLabel.text = ""
        }
    }
}
