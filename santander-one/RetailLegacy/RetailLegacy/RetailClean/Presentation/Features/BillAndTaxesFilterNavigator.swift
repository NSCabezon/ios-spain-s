import Foundation

class BillAndTaxesFilterNavigator: BillAndTaxesFilterNavigatorProtocol {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func navigateToAccounts(_ accounts: [Account], delegate: AccountSelectionDelegate?) {
        let accountSelectionPresenter = presenterProvider.accountSelectorPresenter(accounts: accounts)
        accountSelectionPresenter.delegate = delegate
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(accountSelectionPresenter.view, animated: true)
    }

    func goBack() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
}
