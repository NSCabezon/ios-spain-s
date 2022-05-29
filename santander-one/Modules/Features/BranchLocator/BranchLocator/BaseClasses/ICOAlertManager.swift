import UIKit

typealias AlertCompletion = (_ action: UIAlertAction, _ alert: UIAlertController) -> Void

class ICOAlertManager: NSObject {
	
	class func showAlert(errorString: String?, completion: AlertCompletion?, viewController: UIViewController) {
		showAlert(title: nil, message: errorString, acceptTitle: nil, acceptCompletion: completion, cancelTitle: nil, cancelCompletion: nil, viewController: viewController)
	}
	
	// swiftlint:disable all
	class func showAlert(title: String?, message: String?, acceptTitle: String?, acceptCompletion: AlertCompletion?, cancelTitle: String?, cancelCompletion: AlertCompletion?, isDestructive: Bool = false, viewController: UIViewController) {
		
		var msg = message ?? ""
		
		if (msg == "")
		{
			msg = localizedString("default_error_msg")
		}
		
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		if let cancel = cancelTitle {
			let cancelAction = UIAlertAction(title: cancel, style: isDestructive ? .destructive : .default, handler: { action in
				if let completion = cancelCompletion {
					completion(action, alert)
				}
			})
			alert.addAction(cancelAction)
		}
		
		let accept = acceptTitle ?? localizedString("accept_l")
		let okAction = UIAlertAction(title: accept, style: .default) { action in
			if let completion = acceptCompletion {
				completion(action, alert)
			}
		}
		
		alert.addAction(okAction)
		
		viewController.present(alert, animated: true, completion: nil)
	}
	// swiftlint:enable all
}
