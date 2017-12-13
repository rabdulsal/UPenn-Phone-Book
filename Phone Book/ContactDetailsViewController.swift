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
import Contacts
import AddressBook

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
    
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    var contactService: ContactService!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactService = ContactService(viewController: self, contact: self.contact, delegate: self)
        self.decorateView(with: self.contact)
        self.setupTapGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Check if Contact is already in AddressBook to change contactsButton title to 'Add' vs. 'Edit'
//        self.toggleAddToContactsTitle()
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
        // TODO: Move to AddressBookService
        
        // If Contact is NOT in AddressBook
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .denied, .restricted:
            // Display "Can't Add Contact Alert"
            self.displayCantAddContactAlert()
        case .authorized:
            //2 Add to AddressBook
            self.updateAddressBook(contact: self.contact)
        case .notDetermined:
            //3 Display alert for AddressBook access
            self.promptForAddressBookRequestAccess()
        }
        
        // Contact IS in AddressBook
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
    // TODO: Move to AddressBookService
    func promptForAddressBookRequestAccess() {
        var err: Unmanaged<CFError>? = nil
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            DispatchQueue.main.async {
                if !granted {
                    self.displayCantAddContactAlert()
                } else {
                    self.updateAddressBook(contact: self.contact)
                }
            }
        }
    }
    // TODO: Move to AddressBookService
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    // TODO: Move to AddressBookService
    func displayCantAddContactAlert() {
        // TODO: Turn into lazy var
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
        present(cantAddContactAlert, animated: true, completion: nil)
    }
    
    // TODO: Make method on Contact obj
    func updateAddressBook(contact: Contact) {
        if !self.contactExistsInAddressBook(contact: self.contact) {
            let store = CNContactStore()
            let contactRecord = CNMutableContact()
            // Name
            contactRecord.givenName = contact.firstName
            contactRecord.middleName = contact.middleName
            contactRecord.familyName = contact.lastName
            // Phone Numbers
            contactRecord.phoneNumbers = [
                // Main Phone
                CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: contact.displayPrimaryTelephone)),
                // Mobile Phone
                CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: contact.displayCellPhone))
            ]
            // Email - TODO: Fix error
    //        contactRecord.emailAddresses = [
    //            CNLabeledValue(label: CNLabelWork, value: contact.emailAddress)
    //        ]
            // Work Address
            let workAddress = CNMutablePostalAddress()
            workAddress.street = contact.primaryAddressLine1
            // TODO: Break up address components for city, state, zip
            contactRecord.postalAddresses = [
                CNLabeledValue(label: CNLabelWork, value: workAddress)
            ]
            let saveRequest = CNSaveRequest()
            saveRequest.add(contactRecord, toContainerWithIdentifier: nil)
            // TODO: Wrap in try-catch block and fire off delegate methods
            try! store.execute(saveRequest)
            self.toggleAddToContactsTitle()
        } else {
            SVProgressHUD.showError(withStatus: "\(self.contact.fullName) is already in your AddressBook.")
        }
    }
    // TODO: Move to AddressBookService
    func contactExistsInAddressBook(contact: Contact) -> Bool {
        let store = CNContactStore()
        let contacts = try! store.unifiedContacts(
            matching: CNContact.predicateForContacts(matchingName: contact.lastName),
            keysToFetch:[
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor
            ]
        )
        for c in contacts {
            if c.givenName == contact.firstName && c.middleName == contact.middleName && c.familyName == contact.lastName {
                return true
            }
        }
        return false
    }
    
    func toggleAddToContactsTitle() {
        if self.contactExistsInAddressBook(contact: self.contact) {
            self.addContactsButton.setTitle("Edit Existing Contact", for: .normal)
        } else {
            self.addContactsButton.setTitle("Add to Contacts", for: .normal)
        }
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
