//
//  CardDetailExternalDependenciesResolver.swift
//  Cards
//
//  Created by Gloria Cano López on 17/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol CardDetailExternalDependenciesResolver: ShareDependenciesResolver, NavigationBarExternalDependenciesResolver {
    func resolve() -> CardRepository
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> DependenciesResolver
    func resolve() -> GlobalPositionReloader
    func resolve() -> UINavigationController
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> TimeManager
    func resolve() -> BaseURLProvider
    func resolve() -> [CardTextColorEntity]
    func resolve() -> GetCardsExpensesCalculationUseCase
    func resolve() -> GetCardDetailConfigurationUseCase
    func resolve() -> TrackerManager
    func cardDetailCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func showPANCoordinator() -> BindableCoordinator
    func cardActivateCoordinator() -> BindableCoordinator
    func cardExternalDependenciesResolver() -> CardExternalDependenciesResolver
}

extension CardDetailExternalDependenciesResolver {
    
    public func resolve() -> GetCardDetailConfigurationUseCase {
         DefaultGetCardDetailConfigurationUseCase()
    }
    
    public func cardDetailCoordinator() -> BindableCoordinator {
        return DefaultCardDetailCoordinator(dependencies: self, navigationController: resolve())
    }
    
    public func resolve() -> GetCardsExpensesCalculationUseCase {
        DefaultGetCardsExpensesCalculationUseCase()
    }
    
    public func showPANCoordinator() -> BindableCoordinator {
        DefaultCardShowPANCoordinator(dependencies: cardExternalDependenciesResolver())
    }
}
