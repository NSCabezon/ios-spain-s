protocol SOFIALauncherNavigatorProtocol {
    var presenterProvider: PresenterProvider { get }
    var drawer: BaseMenuViewController { get }
}

extension SOFIALauncherNavigatorProtocol {
    func goToLanding() {
        let presenter = presenterProvider.sofiaPresenter
        let navigation = drawer.currentRootViewController as? NavigationController
        navigation?.pushViewController(presenter.view, animated: true)
    }
}
