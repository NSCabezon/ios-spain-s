//
//  BizumSplitExpensesOperativeLauncher.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 11/01/2021.
//

import Foundation
import Operative
import CoreFoundationLib

public protocol BizumSplitExpensesOperativeLauncher: OperativeContainerLauncher {
    func goToBizumSplitExpenses(_ operation: SplitableExpenseProtocol, handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

public extension BizumSplitExpensesOperativeLauncher {
    func goToBizumSplitExpenses(_ operation: SplitableExpenseProtocol, handler: OperativeLauncherHandler) {
        let dependencies = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependencies, handler: handler)
        handler.showOperativeLoading {
            self.executeUseCase(operation, handler: handler, dependencies: dependencies)
        }
    }
}

private extension BizumSplitExpensesOperativeLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: BizumSplitExpensesFinishingCoordinatorProtocol.self) { _ in
            return BizumSplitExpensesFinishingCoordinator(navigationController: handler.operativeNavigationController, dependeciesResolver: handler.dependenciesResolver)
        }
        
        dependenciesInjector.register(for: BizumTypeUseCase.self) { resolver in
            BizumTypeUseCase(dependenciesResolver: resolver)
        }
    }
    
    func executeUseCase(_ operation: SplitableExpenseProtocol, handler: OperativeLauncherHandler, dependencies: DependenciesDefault) {
        Scenario(useCase: dependencies.resolve(for: BizumTypeUseCase.self), input: BizumTypeUseCaseInput(type: .splitExpenses))
            .execute(on: dependencies.resolve())
            .onSuccess { result in
                switch result {
                case .native(let bizumCheckPaymentEntity):
                    self.goToBizumNative(operation: operation,
                                         bizumCheckPaymentEntity: bizumCheckPaymentEntity,
                                         handler: handler,
                                         dependencies: dependencies)
                case .web(let configuration):
                    handler.hideOperativeLoading {
                        self.goToBizumWeb(configuration: configuration)
                    }
                }
            }.onError { error in
                handler.hideOperativeLoading {
                    handler.showOperativeAlertError(keyTitle: nil, keyDesc: error.getErrorDesc(), completion: nil)
                }
            }
    }
    
    func goToBizumNative(operation: SplitableExpenseProtocol, bizumCheckPaymentEntity: BizumCheckPaymentEntity,
                         handler: OperativeLauncherHandler, dependencies: DependenciesDefault) {
        let operative = BizumSplitExpensesOperative(dependencies: dependencies)
        let amount = operation.amount.value.map({ AmountEntity(value: abs($0)) }) ?? operation.amount
        let operativeData = BizumSplitExpensesOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity, operation: operation, bizumSendMoney: BizumSendMoney(amount: amount, totalAmount: amount, concept: operation.concept))
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}
