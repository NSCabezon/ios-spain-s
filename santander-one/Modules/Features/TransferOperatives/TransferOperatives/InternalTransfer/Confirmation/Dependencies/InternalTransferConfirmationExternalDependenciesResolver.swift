//
//  InternalTransferConfirmationExternalDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Juan Sánchez Marín on 2/3/22.
//

import CoreFoundationLib
import CoreDomain

public protocol InternalTransferConfirmationExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> BaseURLProvider
    func resolve() -> TransfersRepository
    func resolve() -> InternalTransferConfirmationUseCase
    func resolve() -> InternalTransferConfirmationModifierProtocol
    func resolve() -> TrackerManager
}

public extension InternalTransferOperativeExternalDependenciesResolver {
    func resolve() -> InternalTransferConfirmationUseCase {
        return DefaultInternalTransferConfirmationUseCase(dependencies: self)
    }

    func resolve() -> InternalTransferConfirmationModifierProtocol {
        return DefaultInternalTransferConfirmationModifier()
    }
}
