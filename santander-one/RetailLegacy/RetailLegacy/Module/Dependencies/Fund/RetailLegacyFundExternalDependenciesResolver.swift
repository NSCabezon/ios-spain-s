//
//  RetailLegacyFundExternalDependenciesResolver.swift
//  RetailLegacy
//

import UI
import CoreFoundationLib

public protocol RetailLegacyFundExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func fundsHomeCoordinator() -> BindableCoordinator
}
