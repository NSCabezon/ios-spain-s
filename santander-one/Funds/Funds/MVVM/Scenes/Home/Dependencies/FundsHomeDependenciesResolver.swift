//
//  FundsHomeDependenciesResolver.swift
//  Funds
//

import UI
import CoreFoundationLib

protocol FundsHomeDependenciesResolver {
    var external: FundsHomeExternalDependenciesResolver { get }
    func resolve() -> FundHomeViewModel
    func resolve() -> FundsHomeViewController
    func resolve() -> FundsHomeCoordinator
    func resolve() -> SharedHandler
    func resolve() -> GetFundsUseCase
    func resolve() -> GetFundMovementsUseCase
    func resolve() -> DataBinding
}

extension FundsHomeDependenciesResolver {
    func resolve() -> FundHomeViewModel {
        return FundHomeViewModel(dependencies: self)
    }

    func resolve() -> FundsHomeViewController {
        return FundsHomeViewController(dependencies: self)
    }

    func resolve() -> SharedHandler {
        return SharedHandler()
    }

    func resolve() -> GetFundsUseCase {
        return DefaultGetFundsUseCase(dependencies: self)
    }

    func resolve() -> GetFundMovementsUseCase {
        return DefaultGetFundMovementsUseCase(dependencies: self)
    }
}

