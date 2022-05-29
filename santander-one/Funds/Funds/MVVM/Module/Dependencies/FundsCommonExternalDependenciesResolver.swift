//
//  FundsCommonExternalDependenciesResolver.swift
//  Funds
//

public protocol FundsCommonExternalDependenciesResolver {
    func resolve() -> FundMovementDetailFieldsModifier?
    func resolve() -> FundsHomeMovementsModifier?
}

extension FundsCommonExternalDependenciesResolver {
    func resolve() -> FundMovementDetailFieldsModifier? {
        return nil
    }

    func resolve() -> FundsHomeMovementsModifier? {
        nil
    }
}
