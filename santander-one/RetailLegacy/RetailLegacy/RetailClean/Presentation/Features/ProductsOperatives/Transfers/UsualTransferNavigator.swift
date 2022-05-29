protocol UsualTransferNavigatorProtocol {
    func goToSelection<Item: FilterableSortableAndTitleDescriptionRepresentable>(list: [Item], selected: Item?, delegate: TransferSearchableConfigurationSelectionPresenterDelegate)
    func goBack()
    func close()
}

class UsualTransferNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension UsualTransferNavigator: UsualTransferNavigatorProtocol {
    func goToSelection<Item: FilterableSortableAndTitleDescriptionRepresentable>(list: [Item], selected: Item?, delegate: TransferSearchableConfigurationSelectionPresenterDelegate) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        let presenter = presenterProvider.accountOperatives.transferSearchableConfigurationSelectionPresenter(withItems: list, account: nil, selected: selected)
        presenter.delegate = delegate
        navigationController?.pushViewController(presenter.view, animated: true)
    }
    
    func goBack() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func close() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
