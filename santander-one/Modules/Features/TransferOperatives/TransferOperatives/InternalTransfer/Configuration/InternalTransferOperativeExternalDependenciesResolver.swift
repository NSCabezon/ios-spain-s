//
//  InternalTransferOperativeExternalDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import Operative
import UI

public protocol InternalTransferOperativeExternalDependenciesResolver: InternalTransferAccountSelectorExternalDependenciesResolver,
                                                                       InternalTransferDestinationAccountExternalDependenciesResolver,
                                                                       InternalTransferAmountExternalDependenciesResolver,
                                                                       InternalTransferConfirmationExternalDependenciesResolver,
                                                                       InternalTransferSummaryExternalDependenciesResolver,
                                                                       InternalTransferLauncherDependenciesResolver,
                                                                       OpinatorWebViewCoordinatorDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> InternalTransferPreSetupUseCase
    func resolve() -> InternalTransferOperativeCoordinator
    func resolve() -> InternalTransferLauncher
    func opinatorCoordinator() -> BindableCoordinator
}

public extension InternalTransferOperativeExternalDependenciesResolver {
    func opinatorCoordinator() -> BindableCoordinator {
        return OpinatorWebViewCoordinator(dependencies: self)
    }
    
    func resolve() -> InternalTransferOperativeCoordinator {
        return DefaultInternalTransferOperativeCoordinator(dependencies: self)
    }
    
    func resolve() -> InternalTransferPreSetupUseCase {
        return DefaultInternalTransferPreSetupUseCase(dependencies: self)
    }
}
