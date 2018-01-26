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
    
    var delegate: EmailMessageDelegate?
    var canSendMail: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController(mailRecipients: Array<String>) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(mailRecipients)
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled, .saved:
            controller.dismiss()
        case .sent:
            controller.dismiss()
            self.delegate?.messageSent()
        case .failed:
            controller.dismiss()
            if let e = error {
                self.delegate?.messageFailed(errorString: e.localizedDescription)
            }
        }
    }
}
