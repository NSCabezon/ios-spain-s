//
//  GetFundDetailUseCase.swift
//  CoreDomain
//
//  Created by Ernesto Fernandez Calles on 15/3/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetFundDetailUsecase {
    func fechDetailPublisher(fund: FundRepresentable) -> AnyPublisher<FundDetailRepresentable, Error>
}

struct DefaultGetFundDetailUsecase {
    private let repository: FundReactiveRepository

    init(dependencies: FundsHomeExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
}

extension DefaultGetFundDetailUsecase: GetFundDetailUsecase {
    func fechDetailPublisher(fund: FundRepresentable) -> AnyPublisher<FundDetailRepresentable, Error> {
        self.repository.loadDetail(fund: fund)
    }
}
