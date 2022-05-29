//
//  EditFavouriteLauncher.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 20/07/2021.
//

import Foundation
import Operative
import CoreFoundationLib

public protocol EditFavouriteLauncher: OperativeContainerLauncher {
    func goToEditFavourite(selectedFavouriteType: FavoriteType, handler: OperativeLauncherHandler)
}

public extension EditFavouriteLauncher {
    func goToEditFavourite(selectedFavouriteType: FavoriteType, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = EditFavouriteOperative(dependencies: dependenciesEngine)
        let operativeData = EditFavouriteOperativeData(favoriteType: selectedFavouriteType)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}

private extension EditFavouriteLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: EditFavouriteFinishingCoordinatorProtocol.self) { _ in
            return EditFavouriteFinishingCoordinator(navigatorController: handler.operativeNavigationController)
        }
    }
}
