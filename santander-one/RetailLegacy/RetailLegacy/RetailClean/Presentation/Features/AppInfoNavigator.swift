import Foundation

class AppInfoNavigator: AppStoreNavigator, AppInfoNavigatorProtocol {
    
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension AppInfoNavigator: MenuNavigator {
}
