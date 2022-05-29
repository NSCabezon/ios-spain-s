import UIKit
import GlobalPosition
import CoreFoundationLib
import Menu

protocol OtpScaLoginNavigatorProtocol: PublicNavigatable {
    func close()
    func advance(globalPositionOption: GlobalPositionOptionEntity)
}

class OtpScaLoginNavigator {
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    var legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
    }
}

extension OtpScaLoginNavigator: OtpScaLoginNavigatorProtocol {
    
    func close() {
        if let root = drawer.currentRootViewController as? NavigationController {
            if let fakePg = root.children.last as? FakePGViewController, let presenter = fakePg.presenter {
                presenter.backToLogin()
            }
            root.popToRootViewController(animated: false)
        }
    }
    
    func advance(globalPositionOption: GlobalPositionOptionEntity) {
        let pgCoordinator: GlobalPositionModuleCoordinator = dependenciesEngine.resolve(for: GlobalPositionModuleCoordinator.self)
        dependenciesEngine.register(for: GlobalPositionModuleCoordinatorDelegate.self) { resolver in
            return resolver.resolve(for: NavigatorProvider.self).getModuleCoordinator(type: GlobalPositionModuleCoordinatorNavigator.self)
        }
        dependenciesEngine.register(for: LoanSimulatorOfferDelegate.self) { resolver in
            return resolver.resolve(for: NavigatorProvider.self).getModuleCoordinator(type: GlobalPositionModuleCoordinatorNavigator.self)
        }
        dependenciesEngine.register(for: GetInfoSideMenuUseCaseProtocol.self) { _ in
            return GetInfoSideMenuUseCase(dependenciesResolver: self.dependenciesEngine)
        }
        let navigationController: NavigationController = NavigationController()
        drawer.setRoot(viewController: navigationController)
        pgCoordinator.navigationController = navigationController
        switch globalPositionOption {
        case .classic:
            pgCoordinator.start(.classic)
        case .simple:
            pgCoordinator.start(.simple)
        case .smart:
            pgCoordinator.start(.smart)
        }
        let coordinator = self.presenterProvider.navigatorProvider
            .legacyExternalDependenciesResolver
            .privateMenuCoordinator()
        coordinator.start()
        guard let coordinatorNavigator = coordinator.navigationController else { return }
        drawer.setSideMenu(viewController: coordinatorNavigator)
    }
}
