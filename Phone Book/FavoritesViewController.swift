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
    
    enum Identifiers : String {
        case details = "ContactDetailsSegue"
        case cellIdentifier = "FavoritesCell"
        case groupContact = "ContactGroupSegue"
    }
    
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var noFavoritesView: UIView!
    @IBOutlet weak var noFavoritesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noFavoritesLabel: NoDataInstructionsLabel!
    
    var contactService: ContactService!
    var searchService = ContactsSearchService()
    var contactContext : ContactGroupContext = .groupText
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
    let favoritesTitleNibKey     = "FavoritesGroupTitleView"
    let favoritesTitleIdentifier = "FavoritesHeader"
    let contactGroupTitleKey     = "ContactGroupTitleKey"
    let contactGroupMembersKey   = "ContactGroupMembersKey"
    
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
        self.favoritesTableView.delegate = self
        self.favoritesTableView.dataSource = self
        self.favoritesTableView.register(UINib(nibName: self.favoritesTitleNibKey, bundle: nil), forHeaderFooterViewReuseIdentifier: self.favoritesTitleIdentifier)
        self.favoritesTableView.tableFooterView = UIView()
        self.noFavoritesView.backgroundColor = UIColor.upennLightGray
        FavoritesService.loadFavoritesData()
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
            FavoritesService.removeFromFavorites(favoriteContact: favContact, completion: { (success) in
                if success {
                    self.favoritesTableView.reloadData()
                } else {
                    SVProgressHUD.showError(withStatus: "Sorry, there was an error updating this record.")
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
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.favoritesTitleIdentifier) as! FavoritesGroupTitleView
        let title = FavoritesService.getFavoritesGroupTitle(for: section)
        view.configure(with: self, groupTitle: title!, and: section)
        return view
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        FavoritesService.moveContact(from: sourceIndexPath, to: destinationIndexPath)
         self.favoritesTableView.reloadData()
    }
}

extension FavoritesViewController : FavoritesContactDelegate {
    func pressedCallPhoneButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), delegate: self)
        self.contactService.callPhone()
    }
    
    func pressedCallCellButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), delegate: self)
        self.contactService.callCell()
    }
    
    func pressedTextButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), delegate: self)
        self.contactService.sendText()
    }
    
    func pressedEmailButton(for contact: FavoritesContact) {
        self.contactService = ContactService(viewController: self, contact: Contact(favoriteContact: contact), delegate: self)
        self.contactService.sendEmail()
    }
}

extension FavoritesViewController : FavoritesGroupTitleDelegate {
    func pressedTextGroup(groupIndex: Int) {
        self.contactContext = .groupText
        self.performContactGroupSegue(groupIndex: groupIndex)
    }
    
    func pressedEmailGroup(groupIndex: Int) {
        self.contactContext = .groupEmail
        self.performContactGroupSegue(groupIndex: groupIndex)
    }
    
    func pressedEditGroupTitle(groupIndex: Int) {
        print("Pressed Edit Group:",groupIndex)
        // Get GroupTitle
        
        
    }
}

extension FavoritesViewController : ContactServicable {
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

private extension FavoritesViewController {
    func toggleEditing(_ isEditing: Bool) {
        self.favoritesTableView.isEditing = isEditing
        self.editBarButton.title = isEditing ? "Done" : "Reorder"
    }
    
    func toggleNoFavoritesView(show: Bool) {
        if show {
            self.noFavoritesView.isHidden = false
            self.noFavoritesViewHeight.constant = 100
            self.noFavoritesLabel.text = "You have no Favorites. Find Contacts in the Search Tab and Favorite them to see here."
        } else {
            self.noFavoritesView.isHidden = true
            self.noFavoritesViewHeight.constant = 0
            self.noFavoritesLabel.text = ""
        }
    }
    
    func performContactGroupSegue(groupIndex: Int) {
        guard let favoritesGroup = FavoritesService.getFavoritesGroup(for: groupIndex) else { return }
        self.performSegue(withIdentifier: Identifiers.groupContact.rawValue, sender: favoritesGroup)
    }
}
