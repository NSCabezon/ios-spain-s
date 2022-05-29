import Cards

class AddToApplePayFinishNavigator: StopOperativeProtocol {
    
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        if let destination = sourceView?.navigationController?.viewControllers.reversed().first(where: {
            $0 is ApplePayOperativeViewLauncher
        }) {
            sourceView?.navigationController?.popToViewController(destination, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
