import Bills

class BillOperativeFinishNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        if let destination = sourceView?.navigationController?.viewControllers.reversed().first(where: { viewController -> Bool in
            return viewController is BillHomeViewController
        }) {
            sourceView?.navigationController?.popToViewController(destination, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
