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
    @IBOutlet weak var noGroupsView: UIView!
    @IBOutlet weak var noGroupsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noGroupsLabel: NoDataInstructionsLabel!
    
    let cellIdentifier = "favoritesGroupCell"
    var contact: Contact!
    var favoritesGroups : Array<String>? {
        let allFavorites = FavoritesService.getAllFavoritesGroups()
        let hasFavorites = allFavorites.count > 0
        self.updateFavoritesViewInstructions(hasFavorites: hasFavorites)
        return allFavorites
    }
    var addFavoritesDelegate: AddToFavoritesDelegate?
    var createFavoritesAction: UIAlertAction!
    
    var favoritesAlertController : UIAlertController {
        let alertController = UIAlertController(title: "New Favorites Group".localize, message: "Create a name for your new Favorite group".localize, preferredStyle: .alert)
        self.createFavoritesAction = UIAlertAction(title: "Create".localize, style: .default, handler: {
            alert -> Void in
            let textField = alertController.textFields?.first
            if let title = textField?.text, title.isEmpty == false  {
                FavoritesService.addNewFavorite(self.contact, groupTitle: title, completion: { (errorString) in
                    if let e = errorString {
                        SVProgressHUD.showError(withStatus: e)
                    } else {
                        self.dismissWithSuccess(groupTitle: title)
                    }
                })
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .default, handler: nil)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Type group name".localize
            // Pre-populated Group Name
            textField.text = "My Favorites".localize
            textField.addTarget(self, action: #selector(self.createFavoritesTextFieldDidChange(_:)), for: .editingChanged)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(self.createFavoritesAction)
        return alertController
    }
    
    override func viewDidLoad() {
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkEmptyFavoritesAutoDisplay()
    }
    
    override func setup() {
        super.setup()
        self.groupsTableView.delegate = self
        self.groupsTableView.dataSource = self
        self.groupsTableView.tableFooterView = UIView()
        self.noGroupsView.backgroundColor = UIColor.upennLightGray
        self.noGroupsViewHeight.constant = 100
    }
    
    @IBAction func newFavoritesGroupButtonPressed(_ sender: Any) {
        self.present(self.favoritesAlertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss()
    }
}

extension FavoritesGroupsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let title = self.favoritesGroups?[indexPath.row] else {
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong.".localize)
            return
        }
        FavoritesService.addFavoriteContactToExistingGroup(contact: self.contact, groupTitle: title) { (errorString) in
            if let error = errorString {
                SVProgressHUD.showError(withStatus: error.localize)
            } else {
                self.dismissWithSuccess(groupTitle: title)
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
        cell.textLabel?.text = groupTitle.localize
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.favoritesGroups?.count != 0 {
            // Create View
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            view.backgroundColor = UIColor.upennMediumBlue
            // Create Label
            let titleLabel = UPennLabel(frame: CGRect(x: 16, y: 0, width: 200, height: 30))
            titleLabel.textColor = UIColor.white
            titleLabel.text = "Your Favorites Groups".localize
            view.addSubview(titleLabel)
            return view
        }
        return UIView()
    }
}

private extension FavoritesGroupsListViewController {
    func dismissWithSuccess(groupTitle: String) {
        SVProgressHUD.showSuccess(withStatus: "New Contact Successfully Added to \"\(groupTitle)\".".localize)
        self.dismiss()
        self.addFavoritesDelegate?.successfullyAddedContactToFavorites()
    }
    
    func updateFavoritesViewInstructions(hasFavorites: Bool) {
        self.noGroupsLabel.text = hasFavorites ? "Add this person to one of your favorites groups below or select the '+' to create a new group.".localize : "You have no favorites groups. Create one now by pressing the '+' button.".localize
    }
    
    func checkEmptyFavoritesAutoDisplay() {
        if let allFavorites = self.favoritesGroups {
            if allFavorites.count < 1  {
                self.present(self.favoritesAlertController, animated: true, completion: nil)
                
            }
        }
    }
    
    @objc func createFavoritesTextFieldDidChange(_ textField: UITextField) {
        textField.toggleAlertAction(action: self.createFavoritesAction)
    }
}
