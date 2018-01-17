//
//  UITextField+UPenn.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/5/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func addCancelButton() {
        let keyBoardToolbar = UIToolbar()
        keyBoardToolbar.sizeToFit()
        keyBoardToolbar.backgroundColor = UIColor.upennLightGray
        
        let flexibleSpaceBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBarButton = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(UISearchBar.cancel))
        let cancelButtonAttrs: [String: Any] = [
            NSFontAttributeName : UIFont.helvetica(size: 18),
            NSForegroundColorAttributeName: UIColor.upennWarningRed
        ]
        cancelBarButton.setTitleTextAttributes(cancelButtonAttrs, for: UIControlState.normal)
        cancelBarButton.setTitleTextAttributes(cancelButtonAttrs, for: UIControlState.highlighted)
        keyBoardToolbar.items = [flexibleSpaceBarButton, cancelBarButton]
        inputAccessoryView = keyBoardToolbar
    }
    
    func removeDoneButton() {
        inputAccessoryView = nil
    }
    
    func cancel() {
        resignFirstResponder()
    }
}
