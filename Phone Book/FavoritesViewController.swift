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
    
    var searchService = ContactsSearchService()
    var favGroupsCount : Int {
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
                self.favoritesTableView.reloadData()
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
        cell.configure(with: favContact)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return FavoritesService.getFavoritesGroupTitle(for: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.favGroupsCount
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        FavoritesService.moveContact(from: sourceIndexPath, to: destinationIndexPath)
         self.favoritesTableView.reloadData()
    }
}

private extension FavoritesViewController {
    func toggleEditing(_ isEditing: Bool) {
        self.favoritesTableView.isEditing = isEditing
        self.editBarButton.title = isEditing ? "Done" : "Edit"
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
