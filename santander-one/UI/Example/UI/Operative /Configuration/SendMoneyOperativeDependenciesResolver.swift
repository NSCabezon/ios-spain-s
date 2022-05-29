 //
//  SendMoneyOperativeDependenciesResolver.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

 import UI
 import CoreFoundationLib
 import Foundation
 import CoreFoundationLib
 import OpenCombine
 import CoreDomain

protocol SendMoneyOperativeDependenciesResolver {
    var external: SendMoneyOperativeExternalDependenciesResolver { get }
    func resolve() -> NavigationBarExternalDependenciesResolver
    func resolve() -> SendMoneySelectAccountDependenciesResolver
    func resolve() -> DataBinding
    func resolve() -> SendMoneyOperative
    func resolve() -> SendMoneyOperativeCoordinator
    func resolve() -> StepsCoordinator<SendMoneyStep>
    func resolveOpinatorCoordinator() -> BindableCoordinator
}

extension SendMoneyOperativeDependenciesResolver {
    func resolveOpinatorCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
}
