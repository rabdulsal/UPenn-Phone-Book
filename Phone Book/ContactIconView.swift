//
//  ContactIconView.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/29/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol ContactIconViewDelegate {
    func didPressContactButton()
}

class ContactIconView : NibView {
    
    enum IconType : String {
        case Office
        case Mobile
        case Call
        case Email
    }
    
    @IBOutlet weak var contactButton: ContactIconButton!
    @IBOutlet weak var contactTypeLabel: UPennLabel!
    var iconType: IconType = .Email
    var delegate: ContactIconViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func pressedContactButton(_ sender: UIButton) {
        self.delegate?.didPressContactButton()
    }
    
    func configure(with delegate: ContactIconViewDelegate) {
        self.delegate = delegate
    }
    
    func enable() {
        self.contactButton.isHidden = true
        self.contactTypeLabel.isHidden = true
    }
    
    func disable() {
        self.contactButton.isHidden = false
        self.contactTypeLabel.isHidden = false
    }
}

class EmailIconView : ContactIconView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconType = .Email
    }
}

class OfficeIconView : ContactIconView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconType = .Office
    }
}

class CallIconView : ContactIconView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconType = .Call
    }
}

class MobileIconView : ContactIconView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconType = .Mobile
    }
}
