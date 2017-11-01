//
//  FavoritesGroupsListViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/31/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class FavoritesGroupsListViewController : UIViewController {
    
    @IBOutlet weak var groupsTableView : UITableView!
    
    let cellIdentifier = "favoritesGroupCell"
    var contact: Contact!
    var favoritesGroups : Array<String>? {
        return FavoritesService.getAllFavoritesGroups()
    }
    
    override func viewDidLoad() {
        self.setup()
    }
    
    override func setup() {
        super.setup()
        self.groupsTableView.delegate = self
        self.groupsTableView.dataSource = self
    }
    
    @IBAction func newFavoritesGroupButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "New Favorites Group", message: "Enter a name for this new Group", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Create", style: .default, handler: {
            alert -> Void in
            
            let textField = alertController.textFields?.first
            
            if let title = textField?.text, title.isEmpty == false  {
                print("Group Name: \(title)")
                FavoritesService.addToFavorites(self.contact, groupTitle: title, completion: { (favContact) in
                    self.dismissWithSuccess()
                })
            } else {
                SVProgressHUD.showError(withStatus: "Must provide a Group Name")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter New Group Name"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FavoritesGroupsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let title = self.favoritesGroups?[indexPath.row] else {
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong.")
            return
        }
        FavoritesService.addFavoriteContactToExistingGroup(contact: self.contact, groupTitle: title) { (success) in
            if success {
                self.dismissWithSuccess()
            }
        }
    }
    
}

extension FavoritesGroupsListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.favoritesGroups?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier),
            let groupTitle = self.favoritesGroups?[indexPath.row]
            else { return UITableViewCell() }
        cell.textLabel?.text = groupTitle
        return cell
    }
}

private extension FavoritesGroupsListViewController {
    func dismissWithSuccess() {
        SVProgressHUD.showSuccess(withStatus: "New Contact Successfully Added!")
        self.dismiss(animated: true, completion: nil)
    }
}