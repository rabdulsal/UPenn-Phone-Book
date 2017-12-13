//
//  ContactDetailsViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SVProgressHUD

class ContactDetailsViewController : UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var addressLabel1: ActionLabel!
    @IBOutlet weak var addressLabel2: ActionLabel! // TODO: Remove and add to address 1 with new-line break
    @IBOutlet weak var primaryPhoneLabel: ActionLabel!
    @IBOutlet weak var cellPhoneLabel: ActionLabel!
    @IBOutlet weak var emailLabel: ActionLabel!
    @IBOutlet weak var favoriteToggleButton: UIBarButtonItem!
    @IBOutlet weak var callCellButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var callPhoneButton: UIButton!
    @IBOutlet weak var mobileTextLabel: ActionLabel!
    @IBOutlet weak var addContactsButton: PrimaryCTAButton!
    
    var contactService: ContactService!
    var addressBookService: AddressBookService!
    var favoritesDelegate: FavoritesUpdatable?
    var contact: Contact! {
        didSet {
            self.toggleFavoritesButton()
        }
    }
    
    lazy var mapsAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Directions in Apple Maps", message: "You are leaving the Phonebook App to view directions in the Apple Maps App. From Maps, press the 'UPHS Phonebook' button in the upper-left corner to return here.", preferredStyle: .alert)
        let goToMapsAction = UIAlertAction(title: "Go", style: .cancel, handler: {
            alert -> Void in
            self.showInMaps()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(goToMapsAction)
        return alertController
    }()
    
    lazy var cantAddContactAlert : UIAlertController = {
        let cantAddContactAlert = UIAlertController(
            title: "Cannot Add Contact",
            
            message: "You must give the app permission to add the contact first.",
            
            preferredStyle: .alert)
        cantAddContactAlert.addAction(UIAlertAction(
            title: "Change Settings",
            
            style: .default,
            
            handler: { action in
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return cantAddContactAlert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactService = ContactService(viewController: self, contact: self.contact, delegate: self)
        self.addressBookService = AddressBookService(delegate: self)
        self.decorateView(with: self.contact)
        self.setupTapGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addressBookService.checkAddressBookAuthorizationStatus()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as! UINavigationController
        navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        let favsListVC = navVC.viewControllers.first as! FavoritesGroupsListViewController
        favsListVC.contact = self.contact
        favsListVC.addFavoritesDelegate = self
    }
    
    @IBAction func addFavoritesPressed(_ sender: Any) {
        if self.contact.isFavorited {
            FavoritesService.removeFromFavorites(contact: self.contact, completion: { (success) in
                self.contact.isFavorited = false
                self.toggleFavoritesButton()
                self.favoritesDelegate?.successfullyRemovedContactFromFavorites()
            })
        } else {
            self.performSegue(withIdentifier: "FavoritesGroupsSegue", sender: nil)
        }
    }
    
    @IBAction func pressedCallCellButton(_ sender: Any) {
        self.callCell()
    }
    
    @IBAction func pressedTextButton(_ sender: Any) {
        self.sendText()
    }
    
    @IBAction func pressedCallPhoneButton(_ sender: Any) {
        self.callPhone()
    }
    
    @IBAction func pressedAddToContacts(_ sender: UIButton) {
        self.addressBookService.updateAddressBook(contact: self.contact)
    }
    
}

extension ContactDetailsViewController : UIGestureRecognizerDelegate { }

extension ContactDetailsViewController : AddToFavoritesDelegate {
    func successfullyAddedContactToFavorites() {
        self.contact.isFavorited = true
        self.toggleFavoritesButton()
        self.favoritesDelegate?.successfullyAddedContactToFavorites()
    }
}

private extension ContactDetailsViewController {
    
    @objc func callPhone() {
        self.contactService.callPhone()
    }
    
    @objc func callCell() {
        self.contactService.callCell()
    }
    
    @objc func sendText() {
        self.contactService.sendText()
    }
    
    @objc func sendEmail() {
        self.contactService.sendEmail()
    }
    
    func decorateView(with contact: Contact) {
        self.nameLabel.text             = contact.fullName
        self.jobTitleLabel.text         = contact.jobTitle
        self.departmentLabel.text       = contact.department
        self.addressLabel1.text         = contact.primaryAddressLine1
        self.addressLabel2.text         = contact.primaryAddressLine2
        self.primaryPhoneLabel.text     = contact.displayPrimaryTelephone
        self.cellPhoneLabel.text        = contact.displayCellPhone
        self.mobileTextLabel.text       = contact.displayCellPhone
        self.emailLabel.text            = contact.emailAddress
        self.callCellButton.isHidden    = contact.displayCellPhone.isEmpty
        self.textButton.isHidden        = contact.displayCellPhone.isEmpty
        self.callPhoneButton.isHidden   = contact.displayPrimaryTelephone.isEmpty
    }
    
    func setupTapGestureRecognizers() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.callPhone))
        // Office Phone Tap
        tap1.delegate = self
        tap1.numberOfTapsRequired = 1
        primaryPhoneLabel.isUserInteractionEnabled = true
        primaryPhoneLabel.addGestureRecognizer(tap1)
        
        // Work Address Tap
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.displayShowInMapsAlert))
        tap2.delegate = self
        tap2.numberOfTapsRequired = 1
        addressLabel2.isUserInteractionEnabled = true
        addressLabel2.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.displayShowInMapsAlert))
        tap3.delegate = self
        tap3.numberOfTapsRequired = 1
        addressLabel1.isUserInteractionEnabled = true
        addressLabel1.addGestureRecognizer(tap3)
        
        // Email Address Tap
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(self.sendEmail))
        tap4.delegate = self
        tap4.numberOfTapsRequired = 1
        emailLabel.isUserInteractionEnabled = true
        emailLabel.addGestureRecognizer(tap4)
        
        // Text Mobile Number
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(self.sendText))
        tap5.delegate = self
        tap5.numberOfTapsRequired = 1
        mobileTextLabel.isUserInteractionEnabled = true
        mobileTextLabel.addGestureRecognizer(tap5)
        
        // Call Mobile Number
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(self.callCell))
        tap6.delegate = self
        tap6.numberOfTapsRequired = 1
        cellPhoneLabel.isUserInteractionEnabled = true
        cellPhoneLabel.addGestureRecognizer(tap6)
    }
    
    @objc func displayShowInMapsAlert() {
        self.present(self.mapsAlertController, animated: true, completion: nil)
    }
    
    func showInMaps() {
        guard let address1 = contact?.primaryAddressLine1, let address2 = contact?.primaryAddressLine2 else { return }
        let geocoder = CLGeocoder()
        let addStr = address1 + " " + address2
        let regionDistance: CLLocationDistance = 1000
        geocoder.geocodeAddressString(addStr) { (placemarksOptional, error) -> Void in
            guard
                let placemarks = placemarksOptional,
                let placemark = placemarks.first,
                let location = placemark.location else { return }
            
            let regionSpan = MKCoordinateRegionMakeWithDistance(location.coordinate, regionDistance, regionDistance)
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
            let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    func toggleFavoritesButton() {
        self.favoriteToggleButton.title = self.contact.isFavorited ? "Unfavorite" : "Favorite"
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    func displayCantAddContactAlert() {
        present(cantAddContactAlert, animated: true, completion: nil)
    }
    
    func toggleAddToContactsTitle() {
        if self.addressBookService.contactExistsInAddressBook(contact: self.contact) {
            self.addContactsButton.setTitle("Edit Existing Contact", for: .normal)
        } else {
            self.addContactsButton.setTitle("Add to Contacts", for: .normal)
        }
    }
}

extension ContactDetailsViewController : AddressBookDelegate {
    func authorizedAddressBookAccess() {
        self.toggleAddToContactsTitle()
    }
    
    func deniedAddressBookAccess() {
        self.displayCantAddContactAlert()
        DispatchQueue.main.async {
            self.addContactsButton.isEnabled = false
        }
    }
    
    func failedToUpdateContactInAddressBook() {
        SVProgressHUD.showError(withStatus: "Failed to update \(self.contact.fullName) in your AddressBook.")
    }
    
    func contactAlreadyExistsInAddressBook() {
        SVProgressHUD.showError(withStatus: "\(self.contact.fullName) is already in your AddressBook.")
    }
    
    func successfullyUpdatedContactInAddressBook() {
        SVProgressHUD.showSuccess(withStatus: "\(self.contact.fullName) successfully added to your AddressBook.")
        self.toggleAddToContactsTitle()
    }
}

extension ContactDetailsViewController : ContactServicable {
    func cannotEmailError() {
        SVProgressHUD.showError(withStatus: "Sorry, something went wrong. Cannot send email at this time.")
    }
    
    func cannotTextError() {
        SVProgressHUD.showError(withStatus: "Sorry, something went wrong. Cannot send at this time.")
    }
    
    func cannotCallError() {
        SVProgressHUD.showError(withStatus: "Sorry, something went wrong. Cannot make call at this time.")
    }
}
