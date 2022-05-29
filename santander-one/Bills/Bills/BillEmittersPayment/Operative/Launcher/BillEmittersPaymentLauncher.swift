//
//  BillEmittersPaymentLauncher.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import Foundation
import Operative
import CoreFoundationLib

public protocol BillEmittersPaymentLauncher: OperativeContainerLauncher {
    func goToBillEmittersPayment(account: AccountEntity?, handler: OperativeLauncherHandler)
}

public extension BillEmittersPaymentLauncher {
    func goToBillEmittersPayment(account: AccountEntity?, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = BillEmittersPaymentOperative(dependencies: dependenciesEngine)
        let operativeData = BillEmittersPaymentOperativeData(selectedAccount: account)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
    
    private func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: BillEmittersPaymentFinishingCoordinatorProtocol.self) { _ in
            return BillEmittersPaymentFinishingCoordinator(navigatorController: handler.operativeNavigationController)
        }
    }
}
