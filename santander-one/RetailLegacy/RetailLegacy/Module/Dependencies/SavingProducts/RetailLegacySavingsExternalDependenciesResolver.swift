//
//  RetailLegacySavingsExternalDependenciesResolver.swift
//  RetailLegacy
//
//  Created by Adrian Escriche Martin on 15/2/22.
//
import UI
import CoreFoundationLib
import Foundation

public protocol RetailLegacySavingsExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func savingsHomeCoordinator() -> BindableCoordinator
}

