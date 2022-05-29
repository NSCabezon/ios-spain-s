//
//  ShareHandleUseCase.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/11/19.
//

import Foundation
import MessageUI

enum ShareHandleUseCase {
    
    case mail(delegate: MFMailComposeViewControllerDelegate, content: String, subject: String?, toRecipients: [String], isHTML: Bool)
    case sms(delegate: MFMessageComposeViewControllerDelegate, content: String)
    case share(content: String)
    case shareImage(preview: UIShareView, shareView: UIView, onlyWhatsApp: Bool)
    
    func canShare() -> Bool {
        switch self {
        case .mail:
            return MFMailComposeViewController.canSendMail()
        case .sms:
            return MFMessageComposeViewController.canSendText()
        case .share:
            return true
        case .shareImage:
            return true
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
            view.present(controller, animated: true)
        case .sms(let delegate, let content):
            let controller = MFMessageComposeViewController()
            controller.body = content
            controller.messageComposeDelegate = delegate
            view.present(controller, animated: true)
        case .share(let content):
            launchActivityController(info: content, onViewController: view)
        case .shareImage(let preview, let shareView, let onlyWhatsApp):
            view.present(preview, animated: true)
            preview.shareImage(shareView, onlyWhatsApp: onlyWhatsApp) {
                view.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension ShareHandleUseCase: ShareActivityLauncher {}
