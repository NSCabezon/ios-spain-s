//
//  DeleteScheduledTransferLauncher.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 21/7/21.
//

import CoreFoundationLib
import Operative

public protocol DeleteScheduledTransferLauncher: OperativeContainerLauncher {
    func deleteStandingOrder(_ order: ScheduledTransferRepresentable,
                             account: AccountEntity,
                             detail: ScheduledTransferDetailEntity,
                             handler: OperativeLauncherHandler)
}

public extension DeleteScheduledTransferLauncher {
    func deleteStandingOrder(_ order: ScheduledTransferRepresentable, account: AccountEntity, detail: ScheduledTransferDetailEntity, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = DeleteScheduledTransferOperative(dependencies: dependenciesEngine)
        let operativeData = DeleteScheduledTransferOperativeData()
        operativeData.order = order
        operativeData.detail = detail
        operativeData.account = account
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}

private extension DeleteScheduledTransferLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: DeleteScheduledTransferFinishingCoordinatorProtocol.self) { _ in
            return DeleteScheduledTransferFinishingCoordinator(navigatorController: handler.operativeNavigationController)
        }
    }
}
