import UIKit

class TransferSearchableConfigurationSelectionNavigator: AppStoreNavigator, TransferSearchableConfigurationSelectionNavigatorProtocol {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension TransferSearchableConfigurationSelectionNavigator: PullOffersActionsNavigatorProtocol {}
