//
//  UIColor+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/19/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static var upennDeepBlue: UIColor {
        return UIColor(displayP3Red: 25.0/255.0, green: 40.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    }
    
    static var upennDarkBlue: UIColor { // #04498A
        return UIColor(displayP3Red: 4.0/255.0, green: 73.0/255.0, blue: 138.0/255.0, alpha: 1.0)
    }
    
    static var upennMediumBlue: UIColor { // #4EABE6
        return UIColor(displayP3Red: 78.0/255.0, green: 171.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }
    
    static var upennLightGray: UIColor {
        return UIColor(displayP3Red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }
    
    static var upennWarningRed: UIColor {
        return UIColor(displayP3Red: 163.0/255.0, green: 31.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    
    static var upennCTAGreen: UIColor {
        return UIColor(displayP3Red: 130.0/255.0, green: 133.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    
    static var upennCTALightBlue: UIColor {
        return UIColor(displayP3Red: 183.0/255.0, green: 210.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    }
    
    static var upennBlack: UIColor {
        return UIColor(displayP3Red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
    }
}
