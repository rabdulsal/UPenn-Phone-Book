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
    
    var favoriteContacts: Array<FavoritesContact> { return FavoritesService.allFavoritedContacts }
    var searchService = ContactsSearchService()
    
    override func viewDidLoad() {
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoritesTableView.reloadData()
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
    }
}

extension FavoritesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favContact = self.favoriteContacts[indexPath.row]
        let contact = Contact(favoriteContact: favContact)
        self.performSegue(withIdentifier: Identifiers.details.rawValue, sender: contact)
        
        // TODO: Change from Search to transforming FavContact into Contact object, and sending to Segue
//        let profileID = String(describing: Int(contact.phonebookID))
//         self.searchService.makeContactSearchRequest(with: profileID) { (contact, error) in
//            
//            if let e = error {
//                SVProgressHUD.showError(withStatus: e.localizedDescription)
//            } else {
//                self.performSegue(withIdentifier: Identifiers.details.rawValue, sender: contact)
//            }
//        }
    }
}

extension FavoritesViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: FavoritesService needs method that takes a section Int & returns the FavoritesGroup array count
        return self.favoriteContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.cellIdentifier.rawValue) as! FavoritesContactViewCell
        let contact = self.favoriteContacts[indexPath.row]
        cell.configure(with: contact)
        
        return cell
    }
}

extension FavoritesViewController : ToggleFavoritesDelegate {
    func addToFavorites(for indexPath: IndexPath) {
        /*
         * 1. Use IndexPath Section and Row to get FavoritesContact
         * 2. Make AddToFavorites Service call
         * 3. Within completion, get cell using indexPath and toggle the favoritesButton passing 'false'
         */
    }
    
    func removeFromFavorites(for indexPath: IndexPath) {
        /*
         * 1. Use IndexPath Section and Row to get FavoritesContact
         * 2. Make RemoveFromFavorites Service call
         * 3. Within completion, get cell using indexPath and toggle the favoritesButton passing 'false'
         */
    }
}

private extension FavoritesViewController {
    
}
