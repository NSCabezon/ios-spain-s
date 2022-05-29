//
//  ShareCase.swift
//  InboxNotification
//
//  Created by José María Jiménez Pérez on 20/5/21.
//

import CoreFoundationLib
import MessageUI

enum ShareCase {
    case sms
    case mail
    case share
    
    func canShare() -> Bool {
        switch self {
        case .mail:
            return MFMailComposeViewController.canSendMail()
        case .sms:
            return MFMessageComposeViewController.canSendText()
        case .share:
            return true
        }
    }
    
    var shareNotAvailableErrorKey: String {
        switch self {
        case .sms: return "generic_error_canNotSendSms"
        case .mail: return "generic_error_settingsMail"
        default: return ""
        }
    }
}
