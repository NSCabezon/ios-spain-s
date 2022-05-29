import Foundation
import Operative
import CoreFoundationLib

public protocol NewFavouriteLauncher: OperativeContainerLauncher {
    func goToNewFavourite(handler: OperativeLauncherHandler)
}

public extension NewFavouriteLauncher {
    func goToNewFavourite(handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = NewFavouriteOperative(dependencies: dependenciesEngine)
        let operativeData: NewFavouriteOperativeData = dependenciesEngine.resolve()
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}

private extension NewFavouriteLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: NewFavouriteFinishingCoordinatorProtocol.self) { _ in
            return NewFavouriteFinishingCoordinator(navigatorController: handler.operativeNavigationController)
        }
    }
}
