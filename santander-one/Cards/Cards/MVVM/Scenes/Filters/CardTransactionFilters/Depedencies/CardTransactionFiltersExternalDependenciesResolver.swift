//
//  CardTransactionFiltersExternalDependenciesResolver.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 19/4/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol CardTransactionFiltersExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> CardTransactionFilterValidator
    func resolve() -> CardTransactionAvailableFiltersUseCase
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> StringLoader
    func resolve() -> TrackerManager
    func cardTransactionFiltersCoordinator() -> BindableCoordinator
}

extension CardTransactionFiltersExternalDependenciesResolver {
    
    public func resolve() -> CardTransactionFilterValidator {
        return DefaultCardTransactionFilterValidator(dependencies: self)
    }
    
    public func resolve() -> CardTransactionAvailableFiltersUseCase {
        return DefaultCardTransactionAvailableFiltersUseCase()
    }
    
    public func cardTransactionFiltersCoordinator() -> BindableCoordinator {
        return DefaultCardTransactionFiltersCoordinator(dependencies: self, navigationController: resolve())
    }
}
