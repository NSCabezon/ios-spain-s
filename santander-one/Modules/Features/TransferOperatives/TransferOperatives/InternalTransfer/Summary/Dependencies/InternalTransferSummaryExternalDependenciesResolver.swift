//
//  InternalTransferSummaryExternalDependenciesResolver.swift
//  Account
//
//  Created by crodrigueza on 4/3/22.
//

import CoreFoundationLib
import CoreDomain

public protocol InternalTransferSummaryExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> BaseURLProvider
    func resolve() -> InternalTransferSummaryModifierProtocol
    func resolve() -> TrackerManager
}

public extension InternalTransferSummaryExternalDependenciesResolver {
    func resolve() -> InternalTransferSummaryModifierProtocol {
        return DefaultInternalTransferSummaryModifier()
    }
}
