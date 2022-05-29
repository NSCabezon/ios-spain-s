import UIKit

class ChangePasswordOperativeFinishedNavigator {
    let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
}

extension ChangePasswordOperativeFinishedNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let viewController: UIViewController?
        if let personalAreaHomeViewController = (container.operativeContainerNavigator.sourceView?.navigationController?.viewControllers.first { $0 is PersonalAreaViewController }) {
            viewController = personalAreaHomeViewController
        } else {
            viewController = container.operativeContainerNavigator.sourceView?.navigationController?.viewControllers.first
        }
        guard let destinationView = viewController else {
            return
        }

        container.operativeContainerNavigator.sourceView?.navigationController?.popToViewController(destinationView, animated: true)
    }
    
    func onSignatureError(container: OperativeContainerProtocol) {
        guard let sourceView = container.operativeContainerNavigator.sourceView else {
            return
        }
        sourceView.navigationController?.popToViewController(sourceView, animated: true)
    }
}
