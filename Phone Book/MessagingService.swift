//
//  MessagingService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 10/24/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import MessageUI

class MessagingService :
NSObject,
MFMessageComposeViewControllerDelegate,
RecipientsContactable {
    
    var delegate: MessageDelegate?
    var canSendText: Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController(textMessageRecipients: Array<String>) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = textMessageRecipients
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .cancelled:
            controller.dismiss()
        case .sent:
            controller.dismiss()
            self.delegate?.messageSent()
        case .failed:
            controller.dismiss()
            self.delegate?.messageFailed(errorString: "Text message failed to send, please try again.")
        }
    }
}
