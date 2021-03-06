//
//  ContactGroupViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/22/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

enum ContactGroupContext : String {
    case groupText = "text"
    case groupEmail = "email"
}

class ContactGroupViewController : UIViewController {
    
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    fileprivate var groupContacts : [FavoritesContact] {
        return self.favoritesGroups.favoritedContacts
    }
    var contactService: ContactService!
    var favoritesGroups: FavoritesGroup!
    var contactContext: ContactGroupContext = .groupText
    let identifier = "ContactGroupID"
    var footerMessage : String {
        let phrase = self.contactContext == .groupText ? "group-text" : "group-email"
        return "Select the Contacts you want to \(phrase).".localize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func setup() {
        super.setup()
        
        // Configure TableView
        self.groupTableView.allowsMultipleSelection = true
        self.groupTableView.delegate = self
        self.groupTableView.dataSource = self
        
        // NavBar Configs
        self.navigationItem.title = self.contactContext == .groupText ?
            "Text \(self.favoritesGroups.title)".localize :
            "Email \(self.favoritesGroups.title)".localize
        
        // ContactService
        self.configureContactService()
    }
    
    // MARK: IBActions
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func pressedDontButton(_ sender: Any) {
        self.contactContext == .groupText ? self.contactService.textGroup() :
            //            self.contactService.emailGroup() NOTE: Copying Group to Clipboard
        self.contactService.copyEmailGroup()
    }
    
}

extension ContactGroupViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let contact = self.groupContacts[indexPath.row]
        cell?.accessoryType = .checkmark
        self.contactService.addToContactGroup(contact) { (hasContacts) in
            self.toggleDoneButton(isEnabled: hasContacts)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let contact = self.groupContacts[indexPath.row]
        cell?.accessoryType = .none
        self.contactService.removeFromContactGroup(contact) { (hasContacts) in
            self.toggleDoneButton(isEnabled: hasContacts)
        }
    }
}

extension ContactGroupViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.groupContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! UITableViewCell
        let contact = self.groupContacts[indexPath.row]
        if self.contactService.reconcileContactSelectionState(contact: contact) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            cell.accessoryType = .none
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = contact.fullName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Create View
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenGlobals.Width, height: 30))
        view.backgroundColor = UIColor.upennLightGray
        // Create Label
        let titleLabel = UPennLabel(frame: CGRect(x: ScreenGlobals.Padding, y: 10, width: ScreenGlobals.Width - (ScreenGlobals.Padding*2), height: 20))
        titleLabel.textColor = UIColor.upennBlack
        titleLabel.textAlignment = .center
        titleLabel.setFontHeight(size: 13)
        titleLabel.text = self.footerMessage
        view.addSubview(titleLabel)
        return view
    }
}

extension ContactGroupViewController : ContactServicable {
    func copiedToClipboard(message: String) {
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    func cannotCopyToClipboard(message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
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

extension ContactGroupViewController : MessageDelegate {
    func messageSent() {
        SVProgressHUD.showSuccess(withStatus: "Message Sent".localize)
        self.dismiss()
    }
    
    func messageFailed(errorString: String) {
        SVProgressHUD.showError(withStatus: errorString)
    }
}

private extension ContactGroupViewController {
    func toggleDoneButton(isEnabled: Bool) {
        self.doneButton.isEnabled = isEnabled
    }
    
    func configureContactService() {
        // Set up ContactService
        self.contactService = ContactService(viewController: self, contacts: self.groupContacts, emailMessageDelegate: self, contactDelegate: self)
        // Show Error if cannot Email or Text
//        switch self.contactContext {
//        case .groupEmail where !self.contactService.canSendEmail:
//            SVProgressHUD.showError(withStatus: self.contactService.cannotEmailError)
//        case .groupText where !self.contactService.canSendText:
//            SVProgressHUD.showError(withStatus: self.contactService.cannotTextError)
//        default: break
//        }
    }
}
