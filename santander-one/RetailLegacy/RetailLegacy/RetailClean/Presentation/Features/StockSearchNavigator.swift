//

import UIKit

class StockSearchNavigator: StockSearchNavigatorProtocol {
    
    internal let presenterProvider: PresenterProvider
    internal let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func goToStockDetail(stockQuote: StockQuote, stock: Stock?) {
        let stockDetailPresenter = presenterProvider.stockDetailPresenter(stock: stock, stockAccount: nil, stockQuote: stockQuote, origin: .stocksSearch)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(stockDetailPresenter.view, animated: true)
    }
}
