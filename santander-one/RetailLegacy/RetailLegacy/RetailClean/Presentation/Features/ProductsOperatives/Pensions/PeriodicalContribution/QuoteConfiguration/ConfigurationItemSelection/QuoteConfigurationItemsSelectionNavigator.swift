class QuoteConfigurationItemsSelectionNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension QuoteConfigurationItemsSelectionNavigator: QuoteConfigurationItemsSelectionNavigatorProtocol {
    func selectionDone() {
        guard let navigationController = drawer.currentRootViewController as? NavigationController else {
            return
        }
        _ = navigationController.popViewController(animated: true)
    }
}
