import Foundation

class AccountSelectionNavigator: AccountSelectionNavigatorProtocol {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
        
    func close() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
}
