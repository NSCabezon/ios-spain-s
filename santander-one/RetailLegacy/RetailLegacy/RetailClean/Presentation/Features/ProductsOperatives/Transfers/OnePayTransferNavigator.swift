protocol OnePayTransferNavigatorProtocol {
    func goToSelection<Item: FilterableSortableAndTitleDescriptionRepresentable>(account: Account, list: [Item], selected: Item?, delegate: TransferSearchableConfigurationSelectionPresenterDelegate)
    func goBack()
    func goToFavourites(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo, favourites: [FavoriteType])
    func goToOnePayFXTransfer(delegate: DialogOnePayDelegate)
    func close()
}

class OnePayTransferNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension OnePayTransferNavigator: OnePayTransferNavigatorProtocol {
    func goToSelection<Item: FilterableSortableAndTitleDescriptionRepresentable>(account: Account, list: [Item], selected: Item?, delegate: TransferSearchableConfigurationSelectionPresenterDelegate) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        let presenter = presenterProvider.accountOperatives.transferSearchableConfigurationSelectionPresenter(withItems: list, account: account, selected: selected)
        presenter.delegate = delegate
        navigationController?.pushViewController(presenter.view, animated: true)
    }
    
    func goBack() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func goToFavourites(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo, favourites: [FavoriteType]) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        let presenter = presenterProvider.onePayTransferFavouritesPresenter(delegate: delegate, country: country, currency: currency, favourites: favourites)
        let view = presenter.view
        view.modalPresentationStyle = .overCurrentContext
        navigationController?.present(view, animated: true, completion: nil)
    }
    
    func goToOnePayFXTransfer(delegate: DialogOnePayDelegate) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        let presenter = presenterProvider.onePayDialogOnePayPresenter(delegate: delegate)
        let view = presenter.view
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        navigationController?.present(view, animated: true, completion: nil)
    }
    
    func close() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
extension OnePayTransferNavigator: PullOffersActionsNavigatorProtocol {}
