import Foundation
import MessageUI

enum ShareCase {
    
    case mail(delegate: MFMailComposeViewControllerDelegate, content: String, subject: String?, toRecipients: [String], isHTML: Bool)
    case sms(delegate: MFMessageComposeViewControllerDelegate, content: String)
    case share(content: String)
    case shareImage(content: ShareTransferSummaryView)
    
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
            let shareController = CustomActivityViewController(activityItems: [content], applicationActivities: nil)
            shareController.excludedActivityTypes = [.mail, .message]
            view.present(shareController, animated: true)
        case .shareImage(let content):
            view.present(content, animated: true)
            content.shareImage({
                view.dismiss(animated: true, completion: nil)
            })
        }
    }
}

protocol ShowShareType: AnyObject {
    func shareContent(_ content: String)
}

extension BaseViewController: ShowShareType {
    func shareContent(_ content: String) {
        _ = ShareCase.share(content: content).show(from: self)
    }
}

extension BasePresenter: ShowShareType {
    func shareContent(_ content: String) {
        view.shareContent(content)
    }
}

protocol ShareInfoHandler: AnyObject {
    func shareInfoWithCode(_ code: Int?)
}
