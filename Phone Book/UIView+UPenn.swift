//
//  UIView+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/19/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
