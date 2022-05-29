import Foundation
import UIKit

protocol AlertPresentable {
	func presentAlert(title: String?, message: String?, acceptTitle: String?, acceptCompletion: AlertCompletion?, cancelTitle: String?, cancelCompletion: AlertCompletion?, isDestructive: Bool, viewController: UIViewController)
}

extension AlertPresentable {
	func presentAlert(title: String?, message: String?, acceptTitle: String?, acceptCompletion: AlertCompletion?, cancelTitle: String?, cancelCompletion: AlertCompletion?, isDestructive: Bool, viewController: UIViewController) {
		ICOAlertManager.showAlert(title: title,
								  message: message,
								  acceptTitle: acceptTitle,
								  acceptCompletion: acceptCompletion,
								  cancelTitle: cancelTitle,
								  cancelCompletion: cancelCompletion,
								  isDestructive: isDestructive,
								  viewController: viewController)
	}
}

protocol View: class, AlertPresentable {
    
}
