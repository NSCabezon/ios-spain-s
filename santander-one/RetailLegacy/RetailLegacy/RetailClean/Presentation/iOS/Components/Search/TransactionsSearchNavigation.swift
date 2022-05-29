import UIKit

class TransactionsSearchNavigation: TransactionsSearchNavigatorProtocol {
    var presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(drawer: BaseMenuViewController, presenterProvider: PresenterProvider) {
        self.drawer = drawer
        self.presenterProvider = presenterProvider
    }
    
    func closeSearchAndBack() {
        guard let navigationController = drawer.currentRootViewController as? UINavigationController else {
            return
        }
        navigationController.popViewController(animated: true)
    }
    
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate) {
        let presenter: OtpScaAccountPresenter = presenterProvider.otpScaAccountPresenter
        presenter.delegate = delegate
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
}
