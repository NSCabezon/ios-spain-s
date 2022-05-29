import UIKit
import CoreFoundationLib
import BranchLocator

protocol ATMLocatorNavigatable {
    var customNavigation: NavigationController? { get }
    func goToATMLocator(keepingNavigation: Bool)
}

extension ATMLocatorNavigatable {
    func goToATMLocator(keepingNavigation: Bool) {
        guard
            let navigationContainer = customNavigation,
            let mainVC = navigationContainer.viewControllers.first
        else { return }
        navigationContainer.isProgressBarVisible = false
        navigationContainer.navigationBar.tintColor = .santanderRed
        let mainBLVC = MapRouter.createModule(shouldShowTitle: false,
                                              filtersToApply: [],
                                              availableFilters: availableFilters(),
                                              navigationMapsList: [],
                                              urlLauncher: UIApplication.shared)
        mainBLVC.title = localizedString("bl_braches_and_atms")
        let mapNavigator = UINavigationController(rootViewController: mainBLVC)
        let titleTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.santanderRed,
            .font: UIFont.santanderHeadlineBold(size: 20)
        ]
        if #available(iOS 13.0, *) {
            mapNavigator.navigationBar.standardAppearance.titleTextAttributes = titleTextAttributes
            mapNavigator.navigationBar.scrollEdgeAppearance?.titleTextAttributes = titleTextAttributes
        } else {
            mapNavigator.navigationBar.titleTextAttributes = titleTextAttributes
        }
        let vcList = keepingNavigation ? navigationContainer.viewControllers : [mainVC]
        navigationContainer.setViewControllers(vcList + [mainBLVC], animated: true)
    }
}

extension UIApplication: URLLauncher {
    @objc public func canOpen(url: URL) -> Bool {
        return canOpenURL(url)
    }
    
    @objc public func open(url: URL) {
        if #available(iOS 10.0, *) {
            self.open(url, options: [:], completionHandler: nil)
        } else {
            self.openURL(url)
        }
    }
}
