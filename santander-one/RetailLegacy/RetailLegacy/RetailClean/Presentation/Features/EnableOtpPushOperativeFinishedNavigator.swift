import Transfer

enum EnableOtpPushOperativeCloseReason {
    case globalPosition
    case exit
}

class EnableOtpPushOperativeFinishedNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        let operativeData: EnableOtpPushOperativeData = container.provideParameter()
        guard let closeReason = operativeData.closeReason else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
            return
        }
        switch closeReason {
        case .exit:
            toInitialView(container: container)
        case .globalPosition:
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func toInitialView(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        if let sourceView = sourceView, let index = sourceView.navigationController?.viewControllers.firstIndex(of: sourceView), index > 1, let destination = sourceView.navigationController?.viewControllers[index - 1] {
            sourceView.navigationController?.popToViewController(destination, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
