//
//  ShareCase.swift
//  PersonalManager
//
//  Created by alvola on 12/02/2020.
//

import Foundation
import MessageUI

enum ShareCase {
    
    case mail(delegate: MFMailComposeViewControllerDelegate, content: String, subject: String?, toRecipients: [String], isHTML: Bool)
    case sms(delegate: MFMessageComposeViewControllerDelegate, content: String)
//    case share(content: String)
    
    func canShare() -> Bool {
        switch self {
        case .mail:
            return MFMailComposeViewController.canSendMail()
        case .sms:
            return MFMessageComposeViewController.canSendText()
        }
    }
    
    func show(from view: UIViewController) {
        switch self {
        case .mail(let delegate, let content, let subject, let toRecipients, let isHTML):
            let controller = MFMailComposeViewController()
            if let subject = subject {
                controller.setSubject(subject)
            }
            controller.setMessageBody(content, isHTML: isHTML)
            controller.setToRecipients(toRecipients)
            controller.mailComposeDelegate = delegate
            fixRotationOnPreOS13(controller: controller)
            
            view.present(controller, animated: true)
        case .sms(let delegate, let content):
            let controller = MFMessageComposeViewController()
            controller.body = content
            controller.messageComposeDelegate = delegate
            view.present(controller, animated: true)
        }
    }
    
    func fixRotationOnPreOS13(controller: MFMailComposeViewController) {
        guard #available(iOS 13.0, *) else {
            controller.modalPresentationStyle = .overCurrentContext
            return
        }
    }
}
