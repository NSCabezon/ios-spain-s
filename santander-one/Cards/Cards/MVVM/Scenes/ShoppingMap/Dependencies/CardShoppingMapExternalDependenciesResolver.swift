//
//  ShoppingMapMVVMExternalDependenciesResolver.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol CardShoppingMapExternalDependenciesResolver: NavigationBarExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> CardRepository
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> GetDatedCardMovementsLocationsForShoppingMapUseCase
    func resolve() -> GetMultipleCardMovementLocationsForShoppingMapUseCase
    func resolve() -> TrackerManager
    func shoppingMapCoordinator() -> BindableCoordinator
}

public extension CardShoppingMapExternalDependenciesResolver {

    func shoppingMapCoordinator() -> BindableCoordinator {
        return DefaultShoppingMapCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func resolve() -> GetDatedCardMovementsLocationsForShoppingMapUseCase {
        return DefaultGetDatedCardMovementsLocationsUseCase(dependencies: self)
    }
    
    func resolve() -> GetMultipleCardMovementLocationsForShoppingMapUseCase {
        return DefaultGetMultipleCardMovementLocationsUseCase(dependencies: self)
    }
}
