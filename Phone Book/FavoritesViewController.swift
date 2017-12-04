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
    }
    
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var noFavoritesView: UIView!
    @IBOutlet weak var noFavoritesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noFavoritesLabel: NoDataInstructionsLabel!
    
    var contactService: ContactService!
    var searchService = ContactsSearchService()
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
    
    override func viewDidLoad() {
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
        default: break
        }
    }
    
    override func setup() {
        super.setup()
        self.favoritesTableView.delegate = self
        self.favoritesTableView.dataSource = self
        self.favoritesTableView.tableFooterView = UIView()
        self.noFavoritesView.backgroundColor = UIColor.upennLightGray
        FavoritesService.loadFavoritesData()
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
        return FavoritesService.getFavoritesGroup(for: section)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let favContact = FavoritesService.getFavoriteContact(with: indexPath) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.cellIdentifier.rawValue) as! FavoritesContactViewCell
        cell.configure(with: favContact, and: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return FavoritesService.getFavoritesGroupTitle(for: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.favGroupsCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create View
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        view.backgroundColor = UIColor.upennMediumBlue
        // Create Label
        let titleLabel = UPennLabel(frame: CGRect(x: 16, y: 0, width: 200, height: 30))
        titleLabel.textColor = UIColor.white
        titleLabel.text = FavoritesService.getFavoritesGroupTitle(for: section)
        view.addSubview(titleLabel)
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

extension FavoritesViewController : ContactServicable {
    func cannotEmailError() {
        SVProgressHUD.showError(withStatus: "Sorry, something went wrong. Cannot send email at this time.")
    }
    
    func cannotTextError() {
        SVProgressHUD.showError(withStatus: "Sorry, something went wrong. Cannot send text at this time.")
    }
    
    func cannotCallError() {
        SVProgressHUD.showError(withStatus: "Sorry, something went wrong. Cannot make call at this time.")
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
}
