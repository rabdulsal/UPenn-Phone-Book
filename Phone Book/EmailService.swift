//
//  EmailService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/26/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import MessageUI

class EmailService : NSObject, MFMailComposeViewControllerDelegate {
    
    var canSendMail: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController(mailRecipients: Array<String>) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
