import CoreFoundationLib

class StockOperativesPresenterProvider {
    
    var stocksTradeOperativeCCVSelectorPresenter: StocksTradeOperativeCCVSelectorPresenter {
        return StocksTradeOperativeCCVSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var orderTypeSelectorPresenter: OrderTypeSelectorPresenter {
        return OrderTypeSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var orderTitlesAndDatePresenter: OrderTitlesAndDatePresenter {
        return OrderTitlesAndDatePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var stocksTradeConfirmationPresenter: StocksTradeConfirmationPresenter {
        return StocksTradeConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.defaultMifidLauncherNavigator)
    }
    
    let navigatorProvider: NavigatorProvider
    let sessionManager: CoreSessionManager
    let dependencies: PresentationComponent
    
    init(navigatorProvider: NavigatorProvider, sessionManager: CoreSessionManager, dependencies: PresentationComponent) {
        self.navigatorProvider = navigatorProvider
        self.sessionManager = sessionManager
        self.dependencies = dependencies
    }
}
