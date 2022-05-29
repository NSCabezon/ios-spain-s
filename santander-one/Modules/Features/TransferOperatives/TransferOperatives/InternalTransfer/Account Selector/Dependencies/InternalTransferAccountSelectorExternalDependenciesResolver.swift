//
//  InternalTransferAccountSelectorExternalDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol InternalTransferAccountSelectorExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> AccountNumberFormatterProtocol?
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> TrackerManager
    func resolve() -> GetInternalTransferOriginAccountsFilteredUseCase
}

public extension InternalTransferAccountSelectorExternalDependenciesResolver {
    func resolve() -> GetInternalTransferOriginAccountsFilteredUseCase {
        return DefaultGetInternalTransferOriginAccountsFilteredUseCase()
    }
}
