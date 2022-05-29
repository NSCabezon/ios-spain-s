//
//  GetFundsUseCase.swift
//  Funds
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetFundsUseCase {
    func fechFunds() -> AnyPublisher<[FundRepresentable], Never>
}

struct DefaultGetFundsUseCase {
    private var repository: GlobalPositionDataRepository
    
    init(dependencies: FundsHomeDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetFundsUseCase: GetFundsUseCase {
    func fechFunds() -> AnyPublisher<[FundRepresentable], Never> {
        return repository.getGlobalPosition()
            .map(\.fundRepresentables)
            .eraseToAnyPublisher()
    }
}
