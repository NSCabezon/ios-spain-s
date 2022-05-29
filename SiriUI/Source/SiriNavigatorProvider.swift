import UIKit

@available(iOS 12.0, *)
class SiriNavigatorProvider {
    let presenterProvider: SiriPresenterProvider
    let rootViewController: RootViewController
    
    var mainNavigator: SiriMainNavigatorProtocol {
        return SiriMainNavigator(presenterProvider: presenterProvider, navigatorProvider: self, rootViewController: rootViewController)
    }
    
    init(presenterProvider: SiriPresenterProvider, rootViewController: RootViewController) {
        self.presenterProvider = presenterProvider
        self.rootViewController = rootViewController
    }
}
