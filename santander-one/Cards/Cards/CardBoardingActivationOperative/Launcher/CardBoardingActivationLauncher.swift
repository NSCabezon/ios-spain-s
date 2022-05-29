//
//  ActivateCreditAndDebit.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 06/10/2020.
//

import Foundation
import Operative
import CoreFoundationLib

public protocol CardBoardingActivationLauncher: OperativeContainerLauncher {
    var cardExternalDependencies: CardExternalDependenciesResolver { get }
    func goToCardBoardingActivation(card: CardEntity, handler: OperativeLauncherHandler)
}

public extension CardBoardingActivationLauncher {
    func goToCardBoardingActivation(card: CardEntity, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = CardBoardingActivationOperative(dependencies: dependenciesEngine)
        let operativeData = CardBoardingActivationOperativeData(selectedCard: card)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
    
    private func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: CardBoardingActivationFinishingCoordinatorProtocol.self) { resolver in
            return CardBoardingActivationFinishingCoordinator(dependenciesResolver: resolver, navigatorController: handler.operativeNavigationController, externalDependencies: cardExternalDependencies)
        }
    }
}
