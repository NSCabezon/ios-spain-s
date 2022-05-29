//
//  RetailLegacyMenuExternalDependenciesResolver.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/17/21.
//

import UI
import CoreFoundationLib
import Foundation
import UIKit
import CoreFoundationLib

public protocol RetailLegacyMenuExternalDependenciesResolver: CoreDependencies, PublicMenuActionDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolve() -> BaseMenuViewController
    func privateMenuCoordinator() -> Coordinator
    func publicMenuStockholdersCoordinator() -> Coordinator
    func publicMenuSceneCoordinator() -> Coordinator
    func publicMenuHomeTipsCoordinator() -> Coordinator
    func publicMenuOurProductsCoordinator() -> Coordinator
    func globalSearchCoordinator() -> Coordinator
    func publicMenuATMLocatorCoordinator() -> BindableCoordinator
    func publicMenuOffersCoordinator() -> BindableCoordinator
    func analysisAreaHomeCoordinator() -> BindableCoordinator
}

public extension RetailLegacyMenuExternalDependenciesResolver {
    func privateMenuCoordinator() -> Coordinator {
        return PrivateMenuCoordinator(dependencies: self)
    }

    func globalSearchCoordinator() -> Coordinator {
        return GlobalSearchCoordinator(dependencies: self)
    }
    
    func publicMenuATMLocatorCoordinator() -> BindableCoordinator {
        return RetailLegacyPublicMenuCoordinator(dependencies: self)
    }
    
    func publicMenuOffersCoordinator() -> BindableCoordinator {
        return RetailLegacyPublicMenuCoordinator(dependencies: self)
    }
}
