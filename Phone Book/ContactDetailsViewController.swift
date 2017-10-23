//
//  ContactDetailsViewController.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/13/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class ContactDetailsViewController : UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var addressLabel1: UILabel!
    @IBOutlet weak var addressLabel2: UILabel! // TODO: Remove and add to address 1 with new-line break
    @IBOutlet weak var primaryPhoneLabel: UILabel!
    @IBOutlet weak var cellPhoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _contact = self.contact else { return }
        
        self.decorateView(with: _contact)
        self.setupTapGestureRecognizers()
    }
}

extension ContactDetailsViewController : UIGestureRecognizerDelegate { }

private extension ContactDetailsViewController {
    
    func decorateView(with contact: Contact) {
        self.nameLabel.text         = contact.fullName
        self.jobTitleLabel.text     = contact.jobTitle
        self.departmentLabel.text   = contact.department
        self.addressLabel1.text     = contact.primaryAddressLine1
        self.addressLabel2.text     = contact.primaryAddressLine2
        self.primaryPhoneLabel.text = contact.displayPrimaryTelephone
        self.cellPhoneLabel.text    = contact.displayCellPhone
        self.emailLabel.text        = contact.emailAddress
    }
    
    func setupTapGestureRecognizers() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.makePhoneCallable))
        // Office Phone Tap
        tap1.delegate = self
        tap1.numberOfTapsRequired = 1
        primaryPhoneLabel.isUserInteractionEnabled = true
        primaryPhoneLabel.addGestureRecognizer(tap1)
        
        // Cell Phone Tap
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.makeCellCallable))
        tap2.delegate = self
        tap2.numberOfTapsRequired = 1
        cellPhoneLabel.isUserInteractionEnabled = true
        cellPhoneLabel.addGestureRecognizer(tap2)
        
        // Work Address Tap
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.showInMaps))
        tap3.delegate = self
        tap3.numberOfTapsRequired = 1
        addressLabel1.isUserInteractionEnabled = true
        addressLabel1.addGestureRecognizer(tap3)
    }
    
    @objc func makePhoneCallable() {
        if let phone = self.contact?.primaryTelephone, phone.isEmpty == false {
            self.callNumber(phoneNumber: phone)
        }
    }
    
    @objc func makeCellCallable() {
        if let cell = self.contact?.cellphone, cell.isEmpty == false {
            self.callNumber(phoneNumber: cell)
        }
    }
    
    func callNumber(phoneNumber: String) {
        if let url = URL(string: "telprompt:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func showInMaps() {
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
}
