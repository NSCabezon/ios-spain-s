//
//  GetLoandUseCase.swift
//  Pods
//
//  Created by Juan Jose Acosta on 1/3/21.
//
import CoreDomain

public protocol LoanCommonExternalDependenciesResolver {
    func resolve() -> LoanReactiveRepository
    func resolve() -> GetLoanDetailUsecase
}

public extension LoanCommonExternalDependenciesResolver {
    func resolve() -> GetLoanDetailUsecase {
        return DefaultGetLoanDetailUsecase(dependencies: self)
    }
}
