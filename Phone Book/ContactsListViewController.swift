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

// MARK: - Protocols
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
    @IBOutlet weak var noContactsLabel: NoDataInstructionsLabel!
    @IBOutlet weak var helpButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.addCancelButton()
        }
    }
    @IBOutlet weak var loggedOutView: UIView!
    @IBOutlet weak var loggedOutLabel: UITextView!
    
    var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    var searchService = ContactsSearchService()
    var contactsList: Array<Contact>! {
        didSet {
            self.toggleNoContactsView(show: self.contactsList.count == 0)
        }
    }
    let reuseIdentifier = "ContactCell"
    var favIndexPath: IndexPath?
    lazy var helpAlert : UIAlertController = {
        let alertCtrl = UIAlertController(title: "Search Help", message: self.helpText, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertCtrl
    }()
    let helpText = "Using 'Tom Smith' as an example:\nIn the SearchBar, to search by first name then last name, type 'Tom Smith'\nTo search by last name then first name, type 'Smith, Tom.'\nYou can also search with partial spelling like 'T Smith' or 'Sm, T'.".localize
    lazy var loggedOutAttributedString : NSAttributedString = {
        let text = NSMutableAttributedString(string: "To search UPenn staff, please ".localize)
        text.addAttribute(NSFontAttributeName, value: UIFont.helvetica(size: 18), range: NSMakeRange(0, text.length))
        
        let selectablePart = NSMutableAttributedString(string: "login.".localize)
        selectablePart.addAttribute(NSFontAttributeName, value: UIFont.helvetica(size: 18), range: NSMakeRange(0, selectablePart.length))
        // Add an underline to indicate this portion of text is selectable (optional)
        selectablePart.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0,selectablePart.length))
        selectablePart.addAttribute(NSUnderlineColorAttributeName, value: UIColor.upennMediumBlue, range: NSMakeRange(0, selectablePart.length))
        // Add an NSLinkAttributeName with a value of an url or anything else
        selectablePart.addAttribute(NSLinkAttributeName, value: "signin".localize, range: NSMakeRange(0,selectablePart.length))
        
        // Combine the non-selectable string with the selectable string
        text.append(selectablePart)
        
        // Center the text (optional)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        text.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contactsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resetSearchBar()
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
        
        if self.isAuthorizedForLaunch() {
            self.contactsList = [Contact]()
            
            // TableView configs
            self.contactsTableView.delegate = self
            self.contactsTableView.dataSource = self
            self.searchBar.delegate = self
            self.contactsTableView.tableFooterView = UIView()
            
            // Miscellaneous configs
            self.appDelegate?.setLoginDelegate(loginDelegate: self)
            self.noContactsLabel.setFontHeight(size: 20.0)
            self.noContactsView.backgroundColor = UIColor.upennLightGray
            self.setupLoggedOutLabel()
            
            // Since this is the Launch VC, always logout the User on 1st load
            self.appDelegate?.logout()
        } else {
            
        }
    }
    
    // IBActions
    @IBAction func helpPressed(_ sender: Any) {
        self.present(self.helpAlert, animated: true, completion: nil)
    }
    
    // Public
    override func reloadView() {
        super.reloadView()
        self.resetSearchBar()
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
        SVProgressHUD.showSuccess(withStatus: "You are logged in!".localize)
    }
    
    func didReturnAutoFillCredentials(username: String, password: String) { }
    
    func didFailToLoginUser(errorStr: String) {
        SVProgressHUD.showError(withStatus: errorStr)
    }
}

// MARK: - UISearchBarDelegate

extension ContactsListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SVProgressHUD.show()
        self.searchService.makeContactsListSearchRequest(with: searchBar.text!) { (retrievedContacts, hasExcessContacts, error) in
            SVProgressHUD.dismiss()
            searchBar.resignFirstResponder()
            if let e = error {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            } else {
                if retrievedContacts.count == 0 {
                    SVProgressHUD.showError(withStatus: "No results returned.".localize)
                    return
                }
                self.contactsList = retrievedContacts
                self.contactsTableView.reloadData()
                self.contactsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
                
                if hasExcessContacts {
                    SVProgressHUD.showInfo(withStatus: "Displaying the first \(retrievedContacts.count) matching contacts. You may need to narrow your search.".localize)
                }
                
                // Analytics
                if let text = searchBar.text {
                    AnalyticsService.trackSearchEvent(text)
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
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
        // Analytics
        let contact = self.contactsList[self.favIndexPath!.row]
        AnalyticsService.trackFavoriteContact(contact.fullName)
        
        self.updateFavoritesState(favorited: true)
    }
    
    func successfullyRemovedContactFromFavorites() {
        self.updateFavoritesState(favorited: false)
    }
}

// MARK: - Private
private extension ContactsListViewController {
    
    func isAuthorizedForLaunch() -> Bool {
//        if let loggedIn = self.appDelegate?.isLoggedIn, loggedIn {
//            self.toggleLoggedOutView(!loggedIn)
//            self.contactsTableView.reloadData()
//        } else {
//            self.toggleLoggedOutView(true)
//        }
        
        return true
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
        self.contactsTableView.setContentOffset(CGPoint.init(x: 0.0, y: 0.0), animated: true)
    }
    
    func toggleNoContactsView(show: Bool) {
        if show {
            self.noContactsView.isHidden = false
            self.noContactsLabel.text = "Search for a Penn Medicine employee by last name or first name.".localize
        } else {
            self.noContactsView.isHidden = true
            self.noContactsLabel.text = ""
        }
    }
    
    func resetSearchBar() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
    func toggleLoggedOutView(_ shouldShow: Bool) {
        self.loggedOutView.isHidden = !shouldShow
        self.loggedOutLabel.isHidden = !shouldShow
        if shouldShow {
            self.helpButton.isEnabled = false
            self.helpButton.tintColor = UIColor.upennDarkBlue
        } else {
            self.helpButton.isEnabled = true
            self.helpButton.tintColor = UIColor.white
        }
    }
    
    func setupLoggedOutLabel() {
        self.loggedOutLabel.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.upennMediumBlue, NSFontAttributeName: UIFont.helvetica(size: 18)]
        self.loggedOutLabel.attributedText = self.loggedOutAttributedString
        self.loggedOutLabel.isEditable = false
        self.loggedOutLabel.isSelectable = true
        self.loggedOutLabel.delegate = self
    }
    
}

extension ContactsListViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.appDelegate?.setLoginDelegate(loginDelegate: self)
        self.appDelegate?.presentLoginViewController()
        return false
    }
}
