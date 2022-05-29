//
//  GetAccountUnreadMovementsUseCase.swift
//  GlobalPosition
//
//  Created by alvola on 31/10/2019.
//

import CoreFoundationLib
import CoreDomain
import GlobalPosition
import OpenCombine

final class GetPFMAccountUnreadMovementsUseCase: UseCase<GetAccountUnreadMovementsUseCaseInput, GetAccountUnreadMovementsUseCaseOkOutput, StringErrorOutput>, GetAccountUnreadMovementsUseCase, AccountPFMWaiter {
    
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountUnreadMovementsUseCaseInput) throws -> UseCaseResponse<GetAccountUnreadMovementsUseCaseOkOutput, StringErrorOutput> {
        wait(untilFinished: AccountEntity(requestValues.account))
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let userId = globalPosition.userCodeType else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let pfm: PfmHelperProtocol = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        let date = Date().getDateByAdding(days: -89, ignoreHours: true)
        let movements = pfm.getUnreadMovementsFor(userId: userId, date: date, account: AccountEntity(requestValues.account))
        return UseCaseResponse.ok(GetAccountUnreadMovementsUseCaseOkOutput(newMovements: movements ?? 0))
    }
}
