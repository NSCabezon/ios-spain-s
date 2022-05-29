//
//  InternalTransferDestinationAccountExternalDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 15/2/22.
//

import CoreFoundationLib
import CoreDomain

public protocol InternalTransferDestinationAccountExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> AccountNumberFormatterProtocol?
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> TrackerManager
    func resolve() -> GetInternalTransferDestinationAccountsUseCase
}

public extension InternalTransferDestinationAccountExternalDependenciesResolver {
    func resolve() -> GetInternalTransferDestinationAccountsUseCase {
        return DefaultGetInternalTransferDestinationAccountsUseCase()
    }
}
