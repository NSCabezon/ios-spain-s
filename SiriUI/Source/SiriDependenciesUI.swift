@available(iOS 12.0, *)
class SiriDependenciesUI {
    var presenterProvider: SiriPresenterProvider {
        return SiriPresenterProvider()
    }
    var navigatorProvider: SiriNavigatorProvider {
        return SiriNavigatorProvider(presenterProvider: presenterProvider, rootViewController: rootViewController)
    }
    private let rootViewController: RootViewController
    
    init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
    }
}
