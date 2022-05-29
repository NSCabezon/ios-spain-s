class PullOfferBannerNavigator: AppStoreNavigator, PullOfferBannerNavigatorProtocol {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}
extension PullOfferBannerNavigator: PullOffersActionsNavigatorProtocol {}
