import UIKit
import BranchLocator
import Transfer
import GlobalPosition

protocol WithdrawMoneyNavigatorProtocol: OperativesNavigatorProtocol, ATMLocatorNavigatable, PullOffersActionsNavigatorProtocol {
    func goToAtmLocator()
}

final class WithdrawMoneyNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension WithdrawMoneyNavigator: WithdrawMoneyNavigatorProtocol {
    var customNavigation: NavigationController? {
        return drawer.currentRootViewController as? NavigationController
    }
    
    func goToAtmLocator() {
        goToATMLocator(keepingNavigation: false)
    }
}
