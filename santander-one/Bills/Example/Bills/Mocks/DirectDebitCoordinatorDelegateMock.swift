import Bills
import UI
import UIKit
import CoreFoundationLib

final class DirectDebitCoordinatorDelegateMock: DirectDebitCoordinatorDelegate {
    func didSelectDirectDebit(accountEntity: AccountEntity?) {
        showAlertDialog(
            acceptTitle: LocalizedStylableText(text: "OK", styles: nil),
            cancelTitle: nil,
            title: nil,
            body: LocalizedStylableText(text: "You clicked on direct debit!", styles: nil),
            acceptAction: nil,
            cancelAction: nil)
    }
    
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        let alert = UIAlertController(title: title?.text, message: body.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acceptTitle.text, style: .default, handler: { _ in
            acceptAction?()
        }))
        if let cancelTitle = cancelTitle?.text, let cancelAction = cancelAction {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
                cancelAction()
            }))
        }
        viewController.present(alert, animated: true)
    }
}
