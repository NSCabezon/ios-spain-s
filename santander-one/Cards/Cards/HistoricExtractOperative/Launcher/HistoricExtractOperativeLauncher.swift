//
//  HistoricExtractOperativeLauncher.swift
//  Cards
//
//  Created by Ignacio González Miró on 12/11/2020.
//

import Operative
import CoreFoundationLib

public protocol HistoricExtractOperativeLauncher: OperativeContainerLauncher {
    func goToHistoricExtract(_ card: CardEntity, handler: OperativeLauncherHandler, externalDependencies: CardExternalDependenciesResolver)
}

public extension HistoricExtractOperativeLauncher {
    func goToHistoricExtract(_ card: CardEntity,
                             handler: OperativeLauncherHandler,
                             externalDependencies: CardExternalDependenciesResolver) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler, externalDependencies: externalDependencies)
        let operative = HistoricExtractOperative(dependencies: dependenciesEngine, externalDependencies: externalDependencies)
        self.go(to: operative, handler: handler, operativeData: HistoricExtractOperativeData(card))
    }
    
    private func setupDependencies(in dependenciesInjector: DependenciesInjector,
                                   handler: OperativeLauncherHandler,
                                   externalDependencies: CardExternalDependenciesResolver) {
        dependenciesInjector.register(for: HistoricExtractOperativeFinishingCoordinatorProtocol.self) { _ in
            let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
            return HistoricExtractOperativeFinishingCoordinator(dependenciesResolver: dependenciesEngine,
                                                                navigationController: handler.operativeNavigationController,
                                                                externalDependencies: externalDependencies)
        }
    }
}
