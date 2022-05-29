//
//  CardBlockOperativeLauncher.swift
//  Cards
//
//  Created by Laura González on 27/05/2021.
//

import Foundation
import Operative
import CoreFoundationLib

public protocol CardBlockOperativeLauncher: OperativeContainerLauncher {
    func goToCardBlock(card: CardEntity?, handler: OperativeLauncherHandler)
}

public extension CardBlockOperativeLauncher {
    func goToCardBlock(card: CardEntity?, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(dependenciesEngine, handler: handler)
        let operative = CardBlockOperative(dependencies: dependenciesEngine)
        let operativeData = CardBlockOperativeData(selectedCard: card)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
    
    private func setupDependencies(_ dependencies: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependencies.register(for: CardBlockFinishingCoordinatorProtocol.self) { _ in
            return CardBlockFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
    }
}
