import UI
import UIKit
import StoreKit
import Transfer
import Bills

protocol DeepLinkNavigatorProtocol: OperativesNavigatorProtocol, PullOffersActionsNavigatorProtocol {
    func dismissModal()
    func restoreDefaultViewSettings()
    func goToCardPdfExtract(cards: [Card])
    func placeWhereDeeplinkLaunches() -> OperativeLaunchedFrom
}

class DeepLinkNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func dismissModal() {
        if drawer.presentingViewController != nil || drawer.presentedViewController != nil {
            drawer.dismiss(animated: true)
        } else if drawer.isSideMenuVisible {
            drawer.toggleSideMenu()
        }
        
        let lastController = (drawer.currentRootViewController as? NavigationController)?.viewControllers.last
        if lastController?.presentingViewController != nil || lastController?.presentedViewController != nil {
            lastController?.dismiss(animated: true)
        }
    }
    
    func restoreDefaultViewSettings() {
        dismissModal()
        removeProgressBar()
        removeAllTopWindowsViewIfNeeded()
    }
    
    private func removeProgressBar() {
        let navigationController = (drawer.currentRootViewController as? UINavigationController)
        let navigationSubviews = navigationController?.view.subviews ?? []
        navigationSubviews.filter({$0 is LisboaProgressView}).forEach({ $0.removeFromSuperview() })
    }

    func removeAllTopWindowsViewIfNeeded() {
        guard let window = UIApplication.shared.windows.first else { return }
        for view in window.subviews where view is TopWindowViewProtocol {
            view.removeFromSuperview()
        }
    }

    func goToCardPdfExtract(cards: [Card]) {
        let presenter = presenterProvider.cardPdfExtractPresenter(cards: cards)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    func placeWhereDeeplinkLaunches() -> OperativeLaunchedFrom {
        let sourceView = (drawer.currentRootViewController as? NavigationController)
        if sourceView?.viewControllers.contains(where: {$0 is TransferHomeViewController || $0 is ProductHomeViewController || $0 is BillHomeViewController}) == true {
            return .home
        } else if sourceView?.viewControllers.contains(where: {$0 is PersonalAreaViewController}) == true {
            return .personalArea
        } else {
            return .deepLink
        }
    }
}

extension DeepLinkNavigator: DeepLinkNavigatorProtocol {}
