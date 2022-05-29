//
//  OperabilityChangeLauncher.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

import Operative
import CoreFoundationLib

public protocol OperabilityChangeLauncher: OperativeContainerLauncher {
    func goToOperabilityChange(handler: OperativeLauncherHandler)
}

public extension OperabilityChangeLauncher {
    func goToOperabilityChange(handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = OperabilityChangeOperative(dependencies: dependenciesEngine)
        self.go(to: operative, handler: handler, operativeData: OperabilityChangeOperativeData())
    }
    
    private func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: OperabilityChangeFinishingCoordinatorProtocol.self) { _ in
            return OperabilityChangeFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
    }
}
