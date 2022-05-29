import UIKit
import CoreFoundationLib
import Menu

protocol HomeTipsNavigatable {
    var customNavigation: NavigationController? { get }
    var dependenciesResolver: DependenciesResolver { get }
    func goToHomeTips()
}

extension HomeTipsNavigatable {
    func presentHomeTips() {
        guard let navigator = customNavigation, let first = navigator.viewControllers.first  else { return }
        navigator.isProgressBarVisible = false
        navigator.setViewControllers([first], animated: false)
        let coordinator = dependenciesResolver.resolve(for: RetailLegacyExternalDependenciesResolver.self).publicMenuHomeTipsCoordinator()
        coordinator.start()
    }
}
