import UIKit

class BackToPgFinishedNavigator {
}

extension BackToPgFinishedNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        container.operativeContainerNavigator.sourceView?.navigationController?.popToRootViewController(animated: true)
    }
}
