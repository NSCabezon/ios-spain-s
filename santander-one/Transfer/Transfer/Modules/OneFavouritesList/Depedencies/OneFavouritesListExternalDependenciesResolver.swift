//
//  OneFavouritesListExternalDependenciesResolver.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 4/1/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UI

public protocol OneFavouritesListExternalDependenciesResolver: GetReactiveContactsUseCaseDependenciesResolver, SepaInfoDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolveTransferHelpViewCoordinator() -> BindableCoordinator
    func favouriteListCoordinator() -> BindableCoordinator
}

public extension OneFavouritesListExternalDependenciesResolver {
    func favouriteListCoordinator() -> BindableCoordinator {
        return DefaultOneFavouritesListCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func resolveTransferHelpViewCoordinator() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
}
