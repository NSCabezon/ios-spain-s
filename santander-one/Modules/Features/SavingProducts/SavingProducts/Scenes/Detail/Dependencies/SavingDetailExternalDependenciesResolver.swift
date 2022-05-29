//
//  SavingDetailExternalDependenciesResolver.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 25/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain

public protocol SavingDetailExternalDependenciesResolver: ShareDependenciesResolver, NavigationBarExternalDependenciesResolver {

    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolve() -> NavigationBarItemBuilder
    func savingDetailCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> GetSavingProductComplementaryDataUseCase
    func resolve() -> StringLoader
    func resolve() -> TrackerManager
    func resolve() -> GetSavingDetailsInfoUseCase
}

extension SavingDetailExternalDependenciesResolver {

    public func savingDetailCoordinator() -> BindableCoordinator {
        return DefaultSavingDetailCoordinator(dependencies: self, navigationController: resolve())
    }

    public func resolve() -> GetSavingDetailsInfoUseCase {
        return DefaultGetSavingDetailsInfoUseCase()
    }
}
