protocol StocksAlertsConfigurationNavigatorProtocol: AppStoreNavigatable, MenuNavigator {}

class StocksAlertsConfigurationNavigator: AppStoreNavigator, StocksAlertsConfigurationNavigatorProtocol {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        super.init()
    }
}
