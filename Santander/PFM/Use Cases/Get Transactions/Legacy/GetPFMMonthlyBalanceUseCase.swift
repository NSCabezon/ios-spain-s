//
//  GetPFMMonthlyBalanceUseCase.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 4/2/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine

final class GetPFMMonthlyBalanceUseCase: UseCase<Void, GetMonthlyBalanceUseCaseOkOutput, StringErrorOutput>, GetMonthlyBalanceUseCase, MonthsPFMWaiter {
    
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetMonthlyBalanceUseCaseOkOutput, StringErrorOutput> {
        waitUntilMonthsFinished()
        return .ok(GetMonthlyBalanceUseCaseOkOutput(data: pfmController.monthsHistory ?? []))
    }
}

private extension GetPFMMonthlyBalanceUseCase {
    
    private var pfmController: PfmControllerProtocol {
        return dependenciesResolver.resolve(for: PfmControllerProtocol.self)
    }
}
