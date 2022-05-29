//
//  FundExternalDependenciesResolver.swift
//  Santander
//
//  Created by Ernesto Fernandez Calles on 24/3/22.
//

import UI
import Funds
import CoreFoundationLib
import CoreDomain
import Foundation

extension ModuleDependencies: FundsExternalDependenciesResolver {

    var common: FundsCommonExternalDependenciesResolver {
        return self
    }

    func resolve() -> FundReactiveRepository {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }

    func resolve() -> FundsHomeHeaderModifier? {
        return SpainFundsHomeHeaderModifier()
    }

    func resolve() -> GetFundOptionsUsecase {
        return SpainGetFundOptionsUsecase()
    }

    func fundCustomeOptionCoordinator() -> BindableCoordinator {
        return FundCustomeOptionCoordinator(dependencyResolver: self.resolve())
    }

    func resolve() -> FundsDetailFieldsModifier? {
        SpainFundsDetailFieldsModifier()
    }

    func resolve() -> FundsHomeMovementsModifier? {
        return SpainFundsHomeMovementsModifier()
    }

    func resolve() -> FundMovementDetailFieldsModifier? {
        return SpainFundMovementDetailFieldsModifier()
    }
}
