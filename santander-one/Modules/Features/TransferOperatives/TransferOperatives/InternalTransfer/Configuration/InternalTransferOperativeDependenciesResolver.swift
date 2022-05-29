//
//  InternalTransferOperativeDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol InternalTransferOperativeDependenciesResolver: AnyObject {
    var external: InternalTransferOperativeExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> InternalTransferOperative
    func resolve() -> InternalTransferOperativeCoordinator
    func resolve() -> StepsCoordinator<InternalTransferStep>
}
