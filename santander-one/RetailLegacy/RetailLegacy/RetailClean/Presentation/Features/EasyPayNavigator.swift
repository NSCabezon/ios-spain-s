import UIKit
import Cards
import Menu
import CoreFoundationLib


protocol EasyPayNavigatorProtocol {
    func goBack()
}

class EasyPayNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    var dependenciesEngine: DependenciesInjector & DependenciesResolver
    
    required init(presenterProvider: PresenterProvider,
                  drawer: BaseMenuViewController,
                  dependenciesEngine: DependenciesInjector & DependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
}

extension EasyPayNavigator: EasyPayNavigatorProtocol {
    func goBack() {
        guard let navigationController = drawer.currentRootViewController as? UINavigationController else {
            return
        }
        navigationController.popViewController(animated: true)
    }
}

extension EasyPayNavigator: EasyPayNavigatorDelegate {
    func goToFinancing() {
        let navigatorViewController = self.drawer.currentRootViewController as? UINavigationController ?? UINavigationController()
        let menuModuleCoordinator = MenuModuleCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigatorViewController
        )
        presenterProvider.dependenciesEngine.register(for: FinancingCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        presenterProvider.dependenciesEngine.register(for: AccountFinanceableTransactionCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        presenterProvider.dependenciesEngine.register(for: FinanceableTransactionCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        menuModuleCoordinator.start(.financing)
    }
}
