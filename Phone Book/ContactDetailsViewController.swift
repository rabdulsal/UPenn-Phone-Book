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
    @IBOutlet weak var primaryPhoneLabel: UILabel!
    @IBOutlet weak var cellPhoneLabel: UILabel!
    @IBOutlet weak var emailLabel: ActionLabel!
    @IBOutlet weak var favoriteToggleButton: UIBarButtonItem!
    @IBOutlet weak var callCellButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var callPhoneButton: UIButton!
    
    let messagingService = MessagingService()
    let emailService = EmailService()
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
        self.decorateView(with: self.contact)
        self.setupTapGestureRecognizers()
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
        if let cell = self.contact?.cellphone, cell.isEmpty == false {
            self.callNumber(phoneNumber: cell)
        }
    }
    
    @IBAction func pressedTextButton(_ sender: Any) {
        if let cell = self.contact?.cellphone, cell.isEmpty == false {
            self.textNumber(phoneNumber: cell)
        }
    }
    
    @IBAction func pressedCallPhoneButton(_ sender: Any) {
        if let phone = self.contact?.primaryTelephone, phone.isEmpty == false {
            self.callNumber(phoneNumber: phone)
        }
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
    
    func decorateView(with contact: Contact) {
        self.nameLabel.text             = contact.fullName
        self.jobTitleLabel.text         = contact.jobTitle
        self.departmentLabel.text       = contact.department
        self.addressLabel1.text         = contact.primaryAddressLine1
        self.addressLabel2.text         = contact.primaryAddressLine2
        self.primaryPhoneLabel.text     = contact.displayPrimaryTelephone
        self.cellPhoneLabel.text        = contact.displayCellPhone
        self.emailLabel.text            = contact.emailAddress
        self.callCellButton.isHidden    = contact.displayCellPhone.isEmpty
        self.textButton.isHidden        = contact.displayCellPhone.isEmpty
        self.callPhoneButton.isHidden   = contact.displayPrimaryTelephone.isEmpty
    }
    
    func setupTapGestureRecognizers() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.makePhoneCallable))
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
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(self.makeEmailable))
        tap4.delegate = self
        tap4.numberOfTapsRequired = 1
        emailLabel.isUserInteractionEnabled = true
        emailLabel.addGestureRecognizer(tap4)
    }
    
    @objc func makePhoneCallable() {
        if let phone = self.contact?.primaryTelephone, phone.isEmpty == false {
            self.callNumber(phoneNumber: phone)
        }
    }
    
    @objc func makeEmailable() {
        if let email = self.contact?.emailAddress, email.isEmpty == false {
            self.emailContact(emailAddress: email)
        }
    }
    
    func callNumber(phoneNumber: String) {
        if let url = URL(string: "telprompt:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func textNumber(phoneNumber: String) {
        let recipients = [phoneNumber]
        if messagingService.canSendText {
            let messageComposeVC = messagingService.configuredMessageComposeViewController(textMessageRecipients: recipients)
            self.present(messageComposeVC, animated: true, completion: nil)
        } else {
            SVProgressHUD.showError(withStatus: "Cannot send text message from this device.")
        }
    }
    
    func emailContact(emailAddress: String) {
        let recipients = [emailAddress]
        if emailService.canSendMail {
            let emailComposeVC = emailService.configuredMailComposeViewController(mailRecipients: recipients)
            self.present(emailComposeVC, animated: true, completion: nil)
        } else {
            SVProgressHUD.showError(withStatus: "Cannot send email from this device.")
        }
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
        self.favoriteToggleButton.title = self.contact.isFavorited ? "UnFavorite" : "Favorite"
    }
}
