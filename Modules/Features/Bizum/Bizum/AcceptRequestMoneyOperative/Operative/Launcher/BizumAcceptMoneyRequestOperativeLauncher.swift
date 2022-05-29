//
//  BizumAcceptMoneyRequestOperativeLauncher.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 01/12/2020.
//

import Foundation
import Operative
import CoreFoundationLib

public protocol BizumAcceptMoneyRequestOperativeLauncher: OperativeContainerLauncher {
    func goToBizumAcceptMoneyRequest(_ operation: BizumHistoricOperationEntity, handler: OperativeLauncherHandler)
    func goToBizumWeb(configuration: WebViewConfiguration)
}

public extension BizumAcceptMoneyRequestOperativeLauncher {
    func goToBizumAcceptMoneyRequest(_ operation: BizumHistoricOperationEntity, handler: OperativeLauncherHandler) {
        let dependencies = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependencies, handler: handler)
        handler.showOperativeLoading {
            self.executeUseCase(operation, handler: handler, dependencies: dependencies)
        }
    }
}

private extension BizumAcceptMoneyRequestOperativeLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: BizumFinishingCoordinatorProtocol.self) { _ in
            return BizumGoToHomeFinishingCoordinator(navigationController: handler.operativeNavigationController)
        }
        
        dependenciesInjector.register(for: BizumTypeUseCase.self) { resolver in
            BizumTypeUseCase(dependenciesResolver: resolver)
        }
    }
    
    func executeUseCase(_ operation: BizumHistoricOperationEntity, handler: OperativeLauncherHandler, dependencies: DependenciesDefault) {
        Scenario(useCase: dependencies.resolve(for: BizumTypeUseCase.self), input: BizumTypeUseCaseInput(type: .acceptRequest))
            .execute(on: dependencies.resolve())
            .onSuccess { result in
                switch result {
                case .native(let bizumCheckPaymentEntity):
                    self.goToBizumNative(operation: operation,
                                         bizumCheckPaymentEntity: bizumCheckPaymentEntity,
                                         handler: handler,
                                         dependencies: dependencies)
                case .web(let configuration):
                    self.goToBizumWeb(configuration: configuration)
                }
            }.onError { error in
                handler.hideOperativeLoading {
                    handler.showOperativeAlertError(keyTitle: nil, keyDesc: error.getErrorDesc(), completion: nil)
                }
            }
    }
    
    func goToBizumNative(operation: BizumHistoricOperationEntity, bizumCheckPaymentEntity: BizumCheckPaymentEntity,
                         handler: OperativeLauncherHandler, dependencies: DependenciesDefault) {
        guard let amount = operation.amount.flatMap({ AmountEntity(value: Decimal($0)) }) else { return }
        let operative = BizumAcceptMoneyRequestOperative(dependencies: dependencies)
        let operativeData = BizumAcceptMoneyRequestOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity)
        operativeData.operation = operation
        operativeData.bizumSendMoney = BizumSendMoney(amount: amount,
                                                      totalAmount: amount,
                                                      concept: operation.concept ?? "")
        operativeData.bizumContacts = [
            BizumContactEntity(
                identifier: BizumUtils.getIdentifier(operation.emitterAlias, phone: operation.emitterId ?? ""),
                name: nil,
                phone: operation.emitterId ?? "",
                alias: operation.emitterAlias ?? ""
            )
        ]
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }
}
