//

import Foundation

class StockDetailNavigator: AppStoreNavigator {
    var drawer: BaseMenuViewController
    var presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension StockDetailNavigator: OperativesNavigatorProtocol, PullOffersActionsNavigatorProtocol, StockDetailNavigatorProtocol {}
