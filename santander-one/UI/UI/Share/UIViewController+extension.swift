//
//  UIViewController+extension.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/11/19.
//

import MessageUI
import UIKit

extension UIViewController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true)
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled, .saved, .sent:
            dismiss(animated: true)
        default:
            dismiss(animated: true)
        }
    }
}
