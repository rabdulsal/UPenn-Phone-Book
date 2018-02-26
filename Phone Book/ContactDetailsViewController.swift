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
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var addressCopyButton: PrimaryCTAButtonText!
    
    var contactService: ContactService!
    var addressBookService: AddressBookService!
    var favoritesDelegate: FavoritesUpdatable?
    var contact: Contact! {
        didSet {
            self.toggleFavoritesButton()
        }
    }
    
    lazy var mapsAlertController : UIAlertController = {
        let alertController = UIAlertController(
            title: "Directions in Apple Maps".localize,
            message: "You are leaving the Phonebook App to view directions in the Apple Maps App. From Maps, press the 'UPHS Phonebook' button in the upper-left corner to return here.".localize,
            preferredStyle: .alert)
        let goToMapsAction = UIAlertAction(title: "Go".localize, style: .cancel, handler: {
            alert -> Void in
            self.showInMaps()
        })
        let cancelAction = UIAlertAction(title: "Cancel".localize, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(goToMapsAction)
        return alertController
    }()
    
    lazy var cantAddContactAlert : UIAlertController = {
        let cantAddContactAlert = UIAlertController(
            title: "",
            message: "In the future, to add UPHS Phonebook contacts to your iPhone contacts, go to Settings and grant UPHS Phonebook access to 'Contacts'.".localize,
            preferredStyle: .alert)
        cantAddContactAlert.addAction(UIAlertAction(
            title: "Change Settings".localize,
            
            style: .default,
            
            handler: { action in
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK".localize, style: .cancel, handler: nil))
        return cantAddContactAlert
    }()
    
    lazy var selectedFav : UIImage? = {
        return UIImage(named: "fav_navbar")
    }()
    
    lazy var unselectedFav : UIImage? = {
        return UIImage(named: "fav_navbar_unselected")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactService = ContactService(viewController: self, contact: self.contact, emailMessageDelegate: self, contactDelegate: self)
        self.addressBookService = AddressBookService(delegate: self, contactDelegate: self)
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
    
    @IBAction func pressedEmailButton(_ sender: Any) {
        self.sendEmail()
    }
    
    @IBAction func pressedAddToContacts(_ sender: UIButton) {
        self.addressBookService.updateAddressBook(contact: self.contact)
    }
    
    @IBAction func pressedCopyAddressButton(_ sender: PrimaryCTAButtonText) {
        let address = "\(self.contact.primaryAddressLine1) \(self.contact.primaryAddressLine2)"
        UIPasteboard.general.string = address
        SVProgressHUD.showSuccess(withStatus: "Address copied to clipboard.".localize)
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
        self.nameLabel.text             = contact.fullName.localize
        self.jobTitleLabel.text         = contact.jobTitle.localize
        self.departmentLabel.text       = contact.department.localize
        self.addressLabel1.text         = contact.primaryAddressLine1.localize
        self.addressLabel2.text         = contact.primaryAddressLine2.localize
        self.primaryPhoneLabel.text     = contact.displayPrimaryTelephone.localize
        self.cellPhoneLabel.text        = contact.displayCellPhone.localize
        self.mobileTextLabel.text       = contact.displayCellPhone.localize
        self.emailLabel.text            = contact.emailAddress.localize
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
        self.favoriteToggleButton.image = self.contact.isFavorited ? self.selectedFav : self.unselectedFav
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
            self.addContactsButton.setTitle("Update AddressBook Contact".localize, for: .normal)
        } else {
            self.addContactsButton.setTitle("Add to AddressBook".localize, for: .normal)
        }
    }
}

extension ContactDetailsViewController : AddressBookDelegate, AddContactAddressBookDelegate {
    func authorizedAddressBookAccess() {
        self.toggleAddToContactsTitle()
    }
    
    func deniedAddressBookAccess(showMessage: Bool) {
        if showMessage { self.displayCantAddContactAlert() }
        self.addContactsButton.isEnabled = false
    }
    
    func failedToUpdateContactInAddressBook(message: String) {
        SVProgressHUD.showError(withStatus: "Failed to update \(self.contact.fullName) in your AddressBook. \(message)".localize)
    }
    
    func successfullyUpdatedExistingContactInAddressBook() {
        SVProgressHUD.showSuccess(withStatus: "\(self.contact.fullName) successfully updated in your AddressBook.".localize)
        self.toggleAddToContactsTitle()
    }
    
    func successfullyAddedNewContactToAddressBook() {
        SVProgressHUD.showSuccess(withStatus: "\(self.contact.fullName) successfully added to your AddressBook.".localize)
        self.toggleAddToContactsTitle()
    }
}

extension ContactDetailsViewController : ContactServicable {
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

extension ContactDetailsViewController : EmailMessageDelegate {
    func messageSent() {
        SVProgressHUD.showSuccess(withStatus: "Message Sent".localize)
    }
    
    func messageFailed(errorString: String) {
        SVProgressHUD.showError(withStatus: errorString.localize)
    }
}
