protocol TipNavigatorProtocol: MenuNavigator, OperativesNavigatorProtocol, PullOffersActionsNavigatorProtocol {}

class TipNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension TipNavigator: TipNavigatorProtocol {}
