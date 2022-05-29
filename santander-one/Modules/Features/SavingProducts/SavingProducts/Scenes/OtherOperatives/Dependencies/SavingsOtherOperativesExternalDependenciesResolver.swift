//
//  SavingsOtherOperativesExternalDependenciesResolver.swift
//  SavingProducts

import CoreFoundationLib
import UI

public protocol SavingsOtherOperativesExternalDependenciesResolver {
    func resolve() -> GetSavingProductOptionsUseCase
    func resolve() -> TrackerManager
    func savingsCustomOptionCoordinator() -> BindableCoordinator
}

public extension SavingsOtherOperativesExternalDependenciesResolver {
    func resolve() -> GetSavingProductOptionsUseCase {
        return DefaultGetSavingProductOptionsUseCase()
    }

    func savingsCustomOptionCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
}

