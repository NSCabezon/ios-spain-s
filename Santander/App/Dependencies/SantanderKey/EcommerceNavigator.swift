import UIKit
import CoreFoundationLib
import Ecommerce
import RetailLegacy

final class EcommerceNavigator {
    private weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let ecommerceCoordinator: EcommerceModuleCoordinator
    
    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.navigationController = drawer.currentRootViewController as? UINavigationController
        self.dependenciesEngine = dependenciesEngine
        self.ecommerceCoordinator = EcommerceModuleCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController ?? UINavigationController())
    }
}

extension EcommerceNavigator: EcommerceNavigatorProtocol {
    func showEcommerce(_ origin: EcommerceModuleCoordinator.EcommerceSection) {
        showEcommerce(origin, withCode: nil)
    }
    
    func showEcommerce(_ origin: EcommerceModuleCoordinator.EcommerceSection = .mainDefault, withCode lastPurchaseCode: String?) {
        self.dependenciesEngine.register(for: EcommerceInput.self) { _ in
            return EcommerceInput(lastPurchaseCode: lastPurchaseCode)
        }
        // To remove the old EcommerceViewController and present the new (this check if the user press in different push notification, always it shows the last one)
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.last is EcommerceViewController
        else {
            ecommerceCoordinator.start(origin)
            return
        }
        self.navigationController?.viewControllers.removeLast()
        self.ecommerceCoordinator.start(origin)
    }
}
