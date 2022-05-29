class StockTradeOperativeFinishedNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        guard let sourceView = container.operativeContainerNavigator.sourceView else {
            return
        }
        guard let navigationController = sourceView.navigationController else {
            return
        }
        if container.operativeContainerNavigator.sourceView as? StockDetailViewController != nil {
            guard let index = navigationController.viewControllers.firstIndex(of: sourceView), index > 0 else {
                return
            }
            navigationController.popToViewController(navigationController.viewControllers[index - 1], animated: true)
        } else {
            navigationController.popToViewController(sourceView, animated: true)
        }
    }
}
