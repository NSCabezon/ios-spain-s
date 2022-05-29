//
//  CardOnOffOperativeLauncher.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import CoreFoundationLib
import Operative
import CoreDomain

public protocol CardOnOffOperativeLauncher: OperativeContainerLauncher {
    var cardExternalDependencies: CardExternalDependenciesResolver { get }
    func goToCardOnOff(card: CardEntity?, option: CardBlockType, handler: OperativeLauncherHandler)
}

public extension CardOnOffOperativeLauncher {
    func goToCardOnOff(card: CardEntity?, option: CardBlockType, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(dependenciesEngine, handler: handler)
        let operative = CardOnOffOperative(dependencies: dependenciesEngine)
        let operativeData = CardOnOffOperativeData(selectedCard: card, option: option)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
    
    private func setupDependencies(_ dependencies: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependencies.register(for: CardOnOffFinishingCoordinatorProtocol.self) { _ in
            return CardOnOffFinishingCoordinator(navigationController: handler.operativeNavigationController, dependenciesResolver: DependenciesDefault(father: handler.dependenciesResolver), externalDependencies: cardExternalDependencies)
        }
    }
}
