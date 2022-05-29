import RetailLegacy
import UI

protocol UniversalLinkNavigatorProtocol {
    func restoreDefaultViewSettings()
}

final class UniversalLinkNavigator: UniversalLinkNavigatorProtocol {
    var drawer: BaseMenuViewController

    init(drawer: BaseMenuViewController) {
        self.drawer = drawer
    }

    func restoreDefaultViewSettings() {
        self.dismissModal()
        self.removeAllTopWindowsViewIfNeeded()
    }

}

private extension UniversalLinkNavigator {
    func dismissModal() {
        if drawer.presentingViewController != nil || drawer.presentedViewController != nil {
            drawer.dismiss(animated: true)
        } else if drawer.isSideMenuVisible {
            drawer.toggleSideMenu()
        }
    }

    func removeAllTopWindowsViewIfNeeded() {
        guard let window = UIApplication.shared.windows.first else { return }
        for view in window.subviews where view is TopWindowViewProtocol {
            view.removeFromSuperview()
        }
    }
}
