import CoreFoundationLib
import Operative

public protocol DeleteFavouriteLauncher: OperativeContainerLauncher {
    func deleteFavourite(favoriteType: FavoriteType, handler: OperativeLauncherHandler)
}

public extension DeleteFavouriteLauncher {
    func deleteFavourite(favoriteType: FavoriteType, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = DeleteFavouriteOperative(dependencies: dependenciesEngine)
        let operativeData = DeleteFavouriteOperativeData()
        operativeData.favouriteType = favoriteType
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}

private extension DeleteFavouriteLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: DeleteFavouriteFinishingCoordinatorProtocol.self) { _ in
            return DeleteFavouriteFinishingCoordinator(navigatorController: handler.operativeNavigationController)
        }
    }
}
