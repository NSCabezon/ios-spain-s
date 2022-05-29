protocol StocksAlertsConfigurationLauncherNavigatorProtocol {
    var presenterProvider: PresenterProvider { get }
    var drawer: BaseMenuViewController { get }
}

extension StocksAlertsConfigurationLauncherNavigatorProtocol {
    func goToLanding() {
        let presenter = presenterProvider.stocksAlertsConfigurationPresenter
        let navigation = drawer.currentRootViewController as? NavigationController
        navigation?.pushViewController(presenter.view, animated: true)
    }
}
