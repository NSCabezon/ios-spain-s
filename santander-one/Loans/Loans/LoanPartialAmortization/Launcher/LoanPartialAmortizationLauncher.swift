//
//  LoanPartialAmortizationLauncher.swift
//  Loans
//
//  Created by Andres Aguirre Juarez on 22/9/21.
//
import Foundation
import Operative
import CoreFoundationLib

public protocol LoanPartialAmortizationLauncher: OperativeContainerLauncher {
    func goToLoanPartialAmortization(loan: LoanEntity, handler: OperativeLauncherHandler)
}

public extension LoanPartialAmortizationLauncher {
    func goToLoanPartialAmortization(loan: LoanEntity, handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(dependenciesEngine, handler: handler)
        let operative = LoanPartialAmortizationOperative(dependencies: dependenciesEngine)
        let operativeData = LoanPartialAmortizationOperativeData(loan.dto)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
    
    private func setupDependencies(_ dependencies: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependencies.register(for: LoanPartialAmortizationFinishingCoordinatorProtocol.self) { _ in
            return LoanPartialAmortizationFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
    }
}
