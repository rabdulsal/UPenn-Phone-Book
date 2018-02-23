//
//  KeyboardService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 2/22/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

class KeyboardService: NSObject {
    
    weak fileprivate var scrollView:UIScrollView?
    
    init(_ scrollView:UIScrollView) {
        self.scrollView = scrollView
    }
    
    func beginObservingKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardService.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardService.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func endObservingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notif:Notification) {
        if let keyboardFrame = (notif.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            let contentInsets = UIEdgeInsetsMake(scrollView!.contentInset.top, 0, keyboardFrame.height, 0)
            scrollView!.contentInset = contentInsets
            scrollView!.scrollIndicatorInsets = contentInsets
        }
    }
    
    func keyboardDidHide(_ notif:Notification) {
        let contentInset = UIEdgeInsetsMake(scrollView!.contentInset.top, 0, 0, 0)
        scrollView!.contentInset = contentInset
        scrollView!.scrollIndicatorInsets = contentInset
    }
    
}
