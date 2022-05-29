//
//  RetailLegacyTransfersExternalDependenciesResolver.swift
//  RetailLegacy
//
//  Created by Carlos Monfort Gómez on 2/2/22.
//

import CoreFoundationLib
import Transfer
import UI

public protocol RetailLegacyTransfersExternalDependenciesResolver: TransferExternalDependenciesResolver {
    func oneTransferHomeCoordinator() -> BindableCoordinator
}
