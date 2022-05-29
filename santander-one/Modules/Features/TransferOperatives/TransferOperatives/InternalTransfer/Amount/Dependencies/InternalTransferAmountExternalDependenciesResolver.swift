//
//  InternalTransferAmountExternalDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 15/2/22.
//

import UIKit
import CoreFoundationLib

public protocol InternalTransferAmountExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func resolve() -> InternalTransferAmountModifierProtocol?
    func resolve() -> GetInternalTransferAmountExchangeRateUseCase
    func resolve() -> TrackerManager
 }

public extension InternalTransferAmountExternalDependenciesResolver {
    func resolve() -> GetInternalTransferAmountExchangeRateUseCase {
        return DefaultGetInternalTransferAmountExchangeRateUseCase()
    }
    
    func resolve() -> InternalTransferAmountModifierProtocol? {
        return nil
    }
}
