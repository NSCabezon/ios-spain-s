import UIKit
import Loans

class LoansOperativeFinishNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        if let destination = sourceView as? LoansHomeOperativeSource {
            sourceView?.navigationController?.popToViewController(destination, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
