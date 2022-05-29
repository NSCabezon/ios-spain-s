class ContributionQuoteConfigurationNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension ContributionQuoteConfigurationNavigator: ContributionQuoteConfigurationNavigatorProtocol {
    func goToSelection(title: LocalizedStylableText, options: [SelectableConfigurationItem], preselected: Int, delegate: QuoteConfigurationItemsSelectionPresenterDelegate) {
        guard let navigationController = drawer.currentRootViewController as? NavigationController else {
            return
        }
        let presenter = presenterProvider.pensionOperatives.quoteConfigurationItemsSelectionPresenter
        presenter.viewTitle = title
        presenter.options = options
        presenter.delegate = delegate
        presenter.selected = preselected
        
        navigationController.pushViewController(presenter.view, animated: true)
    }
}
