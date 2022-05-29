import Foundation

class CardLimitNavigator: CardLimitNavigatorProtocol {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}
