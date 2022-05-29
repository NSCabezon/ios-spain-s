protocol ApplePayLauncherNavigatorProtocol {
    func goToLanding()
}

class ApplePayLauncherNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension ApplePayLauncherNavigator: ApplePayLauncherNavigatorProtocol {
    
    func goToLanding() {
        let presenter = presenterProvider.applePayPresenter
        let navigation = drawer.currentRootViewController as? NavigationController
        navigation?.pushViewController(presenter.view, animated: true)
    }
}
