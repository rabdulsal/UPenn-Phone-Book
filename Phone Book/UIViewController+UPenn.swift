//
//  UIViewController+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/24/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func setup() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    func reloadView() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
