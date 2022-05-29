protocol StockProfileNavigatorProtocol: OperativesNavigatorProtocol, SOFIALauncherNavigatorProtocol, StocksAlertsConfigurationLauncherNavigatorProtocol {
    
}

class StockProfileNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension StockProfileNavigator: StockProfileNavigatorProtocol {}
