//
//  LegacyInternalTransferLauncher.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 03/01/2020.
//

import Operative
import CoreFoundationLib

public protocol LegacyInternalTransferLauncher: OperativeContainerLauncher {
    var transferExternalDependencies: OneTransferHomeExternalDependenciesResolver { get }
    func goToLegacyInternalTransfer(account: AccountEntity?, handler: OperativeLauncherHandler)
}

public extension LegacyInternalTransferLauncher {
    func goToLegacyInternalTransfer(account: AccountEntity?, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = InternalTransferOperative(dependencies: dependenciesEngine)
        let operativeData = InternalTransferOperativeData(selectedAccount: account)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
    
    private func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: InternalTransferFinishingCoordinatorProtocol.self) { resolver in
            return InternalTransferFinishingCoordinator(
                transferExternalDependencies: transferExternalDependencies,
                navigationController: handler.operativeNavigationController
            )
        }
    }
}
