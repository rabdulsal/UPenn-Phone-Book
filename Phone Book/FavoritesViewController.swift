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
    
    var searchService = ContactsSearchService()
    
    override func viewDidLoad() {
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoritesTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.favoritesTableView.isEditing = false
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
        FavoritesService.loadFavoritesData()
    }
    
    // MARK: IBActions
    
    @IBAction func pressedEditButton(_ sender: Any) {
        if self.favoritesTableView.isEditing {
            self.favoritesTableView.isEditing = false
            self.editBarButton.title = "Edit"
        } else {
            self.favoritesTableView.isEditing = true
            self.editBarButton.title = "Cancel"
        }
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
        return FavoritesService.favoritesGroupsCount
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        FavoritesService.moveContact(from: sourceIndexPath, to: destinationIndexPath)
         self.favoritesTableView.reloadData()
    }
}
