import Transfer

class WithdrawHistoricalOperativeFinishedNavigator: StopOperativeProtocol {
    func onCancelByUser(container: OperativeContainerProtocol) {
        guard
            let sourceView = container.operativeContainerNavigator.sourceView,
            let navigationController = sourceView.navigationController
            else { return }
        if var index = navigationController.viewControllers.firstIndex(of: sourceView) {
            index -= navigationController.viewControllers.contains(where: {$0 is ProductSelectionViewController}) ? 2: 1
            navigationController.setViewControllers(Array(navigationController.viewControllers[0...index]), animated: true)
        } else {
            navigationController.popToRootViewController(animated: true)
        }
    }
}
