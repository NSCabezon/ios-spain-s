//
//  SendMoneyOperativeLauncher.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import Operative
import CoreFoundationLib
import CoreDomain

public protocol SendMoneyOperativeLauncher: OperativeContainerLauncher {
    func goToSendMoney(handler: OperativeLauncherHandler, account: AccountRepresentable?)
}

public extension SendMoneyOperativeLauncher {
    func goToSendMoney(handler: OperativeLauncherHandler, account: AccountRepresentable? = nil) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = SendMoneyOperative(dependencies: dependenciesEngine)
        let operativeData = SendMoneyOperativeData()
        operativeData.selectedAccount = account
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}

private extension SendMoneyOperativeLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: SendMoneyOperativeFinishingCoordinatorProtocol.self) { resolver in
            return SendMoneyOperativeFinishingCoordinator(
                navigationController: handler.operativeNavigationController,
                dependenciesResolver: resolver
            )
        }
    }
}
