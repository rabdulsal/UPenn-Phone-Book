//
//  FavoritesViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/24/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class FavoritesViewController : UIViewController {
    
    fileprivate enum Identifiers : String {
        case details = "ContactDetailsSegue"
        case cellIdentifier = "FavoritesCell"
        case groupContact = "ContactGroupSegue"
    }
    
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var noFavoritesView: UIView!
    @IBOutlet weak var noFavoritesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noFavoritesLabel: NoDataInstructionsLabel!
    
    fileprivate var contactService: ContactService!
    fileprivate var searchService = ContactsSearchService()
    fileprivate var addressbookService: AddressBookService!
    fileprivate var contactContext : ContactGroupContext = .groupText
    fileprivate var selectedGroupTitle = ""
    fileprivate var selectedGroupIndex = -1
    fileprivate let favoritesTitleNibKey     = "FavoritesGroupTitleView"
    fileprivate let favoritesTitleIdentifier = "FavoritesHeader"
    fileprivate let contactGroupTitleKey     = "ContactGroupTitleKey"
    fileprivate let contactGroupMembersKey   = "ContactGroupMembersKey"
    fileprivate var updateFavoritesAction: UIAlertAction!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoritesTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.toggleEditing(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = Identifiers.init(rawValue: segue.identifier!) else { return }
        
        switch segueID {
        case .details:
            guard let contact = sender as? Contact else { return }
            let vc = segue.destination as! ContactDetailsViewController
            vc.contact = contact
        case .groupContact:
            guard let favGroups = sender as? FavoritesGroup else { return }
            let navVC = segue.destination as! UINavigationController
            navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            let groupContactsVC = navVC.viewControllers.first as! ContactGroupViewController
            groupContactsVC.contactContext = self.contactContext
            groupContactsVC.favoritesGroups = favGroups
        default: break
        }
    }
    
    override func setup() {
        super.setup()
        
        // TableView Configs
        self.favoritesTableView.delegate = self
        self.favoritesTableView.dataSource = self
        self.favoritesTableView.register(UINib(nibName: self.favoritesTitleNibKey, bundle: nil), forHeaderFooterViewReuseIdentifier: self.favoritesTitleIdentifier)
        self.favoritesTableView.tableFooterView = UIView()
        self.noFavoritesView.backgroundColor = UIColor.upennLightGray
        
        // Favorites Data
        FavoritesService.loadFavoritesData()
        
        // AddressBook
        self.addressbookService = AddressBookService(groupDelegate: self)
        
        // Navigation
        self.editBarButton.title = "Reorder".localize
    }
    
    override func reloadView() {
        super.reloadView()
        self.favoritesTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            self.favoritesTableView.setContentOffset(.zero, animated: false)
        })
    }
    
    // MARK: IBActions
    
    @IBAction func pressedEditButton(_ sender: Any) {
        self.toggleEditing(!self.favoritesTableView.isEditing)
    }
}

// MARK: - UITableViewDelegate
extension FavoritesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let favContact = FavoritesService.getFavoriteContact(with: indexPath) else { return }
        let contact = Contact(favoriteContact: favContact)
        self.performSegue(withIdentifier: Identifiers.details.rawValue, sender: contact)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let favContact = FavoritesService.getFavoriteContact(with: indexPath) else { return }
        if editingStyle == .delete {
            FavoritesService.removeFromFavorites(favoriteContact: favContact, completion: { (errorString) in
                if let e = errorString {
                    SVProgressHUD.showError(withStatus: e)
                } else {
                    self.favoritesTableView.reloadData()
                }
            })
        }
    }
}

// MARK: - UITableViewDataSource
extension FavoritesViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesService.getFavoritesContacts(for: section)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let favContact = FavoritesService.getFavoriteContact(with: indexPath) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.cellIdentifier.rawValue) as! FavoritesContactViewCell
        cell.configure(with: favContact, and: self)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.favGroupsCount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.favoritesTitleIdentifier) as! FavoritesGroupTitleView
        guard let title = FavoritesService.getFavoritesGroupTitle(for: section) else { return UIView() }
        let textableCount = FavoritesService.getTextableFavorites(for: section)?.count ?? 0
        let emailableCount = FavoritesService.getEmailableFavorites(for: section)?.count ?? 0
        view.configure(with: self, groupTitle: title, groupTextIsVisible: textableCount > 1, groupEmailIsVisible: emailableCount > 1, and: section)
        return view
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        FavoritesService.moveContact(from: sourceIndexPath, to: destinationIndexPath)
         self.favoritesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
}

// MARK: - FavoritesContactDelegate

extension FavoritesViewController : FavoritesContactDelegate {
    func pressedCallPhoneButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), emailMessageDelegate: self, contactDelegate: self)
        self.contactService.callPhone()
    }
    
    func pressedCallCellButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), emailMessageDelegate: self, contactDelegate: self)
        self.contactService.callCell()
    }
    
    func pressedTextButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), emailMessageDelegate: self, contactDelegate: self)
        self.contactService.sendText()
    }
    
    func pressedEmailButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), emailMessageDelegate: self, contactDelegate: self)
        self.contactService.sendEmail()
    }
}

// MARK: - FavoritesGroupTitleDelegate

extension FavoritesViewController : FavoritesGroupTitleDelegate {
    func pressedTextGroup(groupIndex: Int) {
//        self.contactContext = .groupText
//        self.performContactGroupSegue(groupIndex: groupIndex)
        // TODO: Test Launch Favorites ActionSheet
        self.selectedGroupIndex = groupIndex
        self.present(self.moreFavoritesActionsController, animated: true, completion: nil)
    }
    
    func pressedEmailGroup(groupIndex: Int) {
        self.contactContext = .groupEmail
        self.performContactGroupSegue(groupIndex: groupIndex)
    }
    
    func pressedEditGroupTitle(groupIndex: Int) {
        guard let favoritesGroup = FavoritesService.getFavoritesGroup(for: groupIndex) else { return }
        self.selectedGroupTitle = favoritesGroup.title
        self.present(self.editFavoritesGroupAlert, animated: true, completion: nil)
    }
    
    func pressedMoreButton(groupIndex: Int) {
        self.selectedGroupIndex = groupIndex
        self.present(self.moreFavoritesActionsController, animated: true, completion: nil)
    }
}

// MARK: - AddGroupAddressBookDelegate

extension FavoritesViewController : AddGroupAddressBookDelegate {
    func successfullyAddedGroupToAddressBook(groupName: String, isUpdatingGroup: Bool) {
        if isUpdatingGroup {
            self.updateGroupTitle(newTitle: groupName)
            SVProgressHUD.showSuccess(withStatus: "Successfully updated '\(groupName)' Group!".localize)
            return
        }
        SVProgressHUD.showSuccess(withStatus: "Successfully added \(groupName) Group to AddressBook!".localize)
    }
    
    func failedToAddGroupToAddressBook(message: String) {
        SVProgressHUD.showError(withStatus: message.localize)
    }
}

// MARK: - ContactServicable

extension FavoritesViewController : ContactServicable {
    func cannotEmailError(message: String) {
        SVProgressHUD.showError(withStatus: message.localize)
    }
    
    func cannotTextError(message: String) {
        SVProgressHUD.showError(withStatus: message.localize)
    }
    
    func cannotCallError(message: String) {
        SVProgressHUD.showError(withStatus: message.localize)
    }
}

// MARK: - EmailMessageDelegate

extension FavoritesViewController : EmailMessageDelegate {
    func messageSent() {
        SVProgressHUD.showSuccess(withStatus: "Message Sent".localize)
    }
    
    func messageFailed(errorString: String) {
        SVProgressHUD.showError(withStatus: errorString.localize)
    }
}

// MARK: - Private

private extension FavoritesViewController {
    var favGroupsCount : Int {
        /* Dynamically compute favoritesGroupsCount to:
         * 1. Enable/disable Editing state
         * 2. Toggle NoFavoritesView
         */
        let groupsCount = FavoritesService.favoritesGroupsCount
        self.editBarButton.isEnabled = groupsCount != 0
        if !self.editBarButton.isEnabled { self.toggleEditing(false) }
        self.toggleNoFavoritesView(show: groupsCount == 0)
        return groupsCount
    }
    
    var editFavoritesGroupAlert : UIAlertController {
        let alertController = UIAlertController(
            title: "Rename Favorites Group '\(self.selectedGroupTitle)'".localize,
            message: "Type a new name for '\(self.selectedGroupTitle)' Group.".localize,
            preferredStyle: .alert
        )
        self.updateFavoritesAction = UIAlertAction(
            title: "Save".localize,
            style: .default,
            handler: {
                alert -> Void in
                let textField = alertController.textFields?.first
                if let title = textField?.text, title.isEmpty == false  {
                    let favs = FavoritesService.getFavoritesContacts(with: self.selectedGroupTitle)
                    self.updateGroupTitle(newTitle: title, for: favs)
                }
        })
        self.updateFavoritesAction.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Type new group name".localize
            textField.addTarget(self, action: #selector(self.updateFavoritesTextFieldDidChange(_:)), for: .editingChanged)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(self.updateFavoritesAction)
        return alertController
    }
    
    var moreFavoritesActionsController : UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet
        )
        // Bools to conditionally determine display of Email or Text Actions
        var hasTextableGroup : Bool {
            guard let textableCount = FavoritesService.getTextableFavorites(for: self.selectedGroupIndex)?.count else { return false }
            return textableCount > 1
        }
        var hasEmailableGroup : Bool {
            guard let emailableCount = FavoritesService.getEmailableFavorites(for: self.selectedGroupIndex)?.count else { return false }
            return emailableCount > 1
        }
        
        // Group Text Action
        let groupTextAction = UIAlertAction(
            title: "Text Group".localize,
            style: .default,
            handler: {
                alert -> Void in
                self.contactContext = .groupText
                self.performContactGroupSegue(groupIndex: self.selectedGroupIndex)
        })
        
        // Group Email Action
        let groupEmailAction = UIAlertAction(
            title: "Email Group".localize,
            style: .default,
            handler: {
                alert -> Void in
                self.contactContext = .groupEmail
                self.performContactGroupSegue(groupIndex: self.selectedGroupIndex)
        })
        
        // Add All to AddressBook Action
        let groupAddressBookAction = UIAlertAction(
            title: "Add Group to AddressBook".localize,
            style: .default,
            handler: {
                alert -> Void in
                guard
                    let contacts = FavoritesService.getFavoritesContacts(for: self.selectedGroupIndex),
                    let favsGroup = FavoritesService.getFavoritesGroup(for: self.selectedGroupIndex) else { return }
                self.addressbookService.addGroupToAddressBook(contacts: contacts, groupName: favsGroup.title)
        })
        
        // Remove Group
        let deleteGroupAction = UIAlertAction(
            title: "Remove Group from Favorites",
            style: .destructive) { (action) in
                guard
                    let contacts = FavoritesService.getFavoritesContacts(for: self.selectedGroupIndex),
                    let favsGroup = FavoritesService.getFavoritesGroup(for: self.selectedGroupIndex) else { return }
                FavoritesService.removeGroupFromFavorites(favoritesContacts: contacts, completion: { (errorMessage) in
                    if let message = errorMessage {
                        SVProgressHUD.showError(withStatus: message)
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "Successfully removed \(favsGroup.title) Group from Favorites.".localize)
                        self.favoritesTableView.reloadData()
                    }
                })
        }
        
        // Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        // Conditionally display separate
        if hasTextableGroup { alertController.addAction(groupTextAction) }
        if hasEmailableGroup { alertController.addAction(groupEmailAction) }
        if self.addressbookService.hasGrantedAddressBookAccess { alertController.addAction(groupAddressBookAction) }
        if hasTextableGroup || hasEmailableGroup { alertController.addAction(deleteGroupAction) }
        alertController.addAction(cancelAction)
        return alertController
    }
    
    func toggleEditing(_ isEditing: Bool) {
        self.favoritesTableView.isEditing = isEditing
        self.editBarButton.title = isEditing ? "Done".localize : "Reorder".localize
    }
    
    func toggleNoFavoritesView(show: Bool) {
        if show {
            self.noFavoritesView.isHidden = false
            self.noFavoritesViewHeight.constant = 100
            self.noFavoritesLabel.text = "You have no Favorites. Find Contacts in the Search Tab and Favorite them to see here.".localize
        } else {
            self.noFavoritesView.isHidden = true
            self.noFavoritesViewHeight.constant = 0
            self.noFavoritesLabel.text = ""
        }
    }
    
    func performContactGroupSegue(groupIndex: Int) {
        /*
         * Must ensure that segued FavoritesGroup only include Contacts with text numbers and email addresses
         * 1. Create contactable FavoritesGroup based on contactContext
         * 2. Perform segue with contactable FavoritesGroup
         */
        if self.contactContext == .groupText {
            guard let textableFavs = FavoritesService.getTextableFavorites(for: groupIndex) else { return }
            let textGroup = FavoritesGroup(with: textableFavs)
            self.performSegue(withIdentifier: Identifiers.groupContact.rawValue, sender: textGroup)
        } else {
            guard let emailableFavs = FavoritesService.getEmailableFavorites(for: groupIndex) else { return }
            let emailGroup = FavoritesGroup(with: emailableFavs)
            self.performSegue(withIdentifier: Identifiers.groupContact.rawValue, sender: emailGroup)
        }
    }
    
    @objc func updateFavoritesTextFieldDidChange(_ textField: UITextField) {
        textField.toggleAlertAction(action: self.updateFavoritesAction)
    }
    
    func updateGroupTitle(newTitle: String, for contacts: Array<FavoritesContact>) {
        if self.addressbookService.groupExistsInAddressBook(groupTitle: self.selectedGroupTitle) {
            self.addressbookService.updateGroupTitle(from: self.selectedGroupTitle, to: newTitle, for: contacts)
        } else {
            self.updateGroupTitle(newTitle: newTitle)
        }
    }
    
    func updateGroupTitle(newTitle: String) {
        FavoritesService.updateFavoritesGroupTitle(from: self.selectedGroupTitle, to: newTitle.trim, completion: { (errorString) in
            if let e = errorString {
                SVProgressHUD.showError(withStatus: e)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Successfully updated '\(newTitle)' Group!".localize)
                self.favoritesTableView.reloadData()
            }
        })
    }
}
