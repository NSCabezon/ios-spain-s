//
//  GetCardUnreadMovementsUseCase.swift
//  GlobalPosition
//
//  Created by alvola on 31/10/2019.
//

import CoreFoundationLib
import CoreDomain
import GlobalPosition
import OpenCombine

final class GetPFMCardUnreadMovementsUseCase: UseCase<GetCardUnreadMovementsUseCaseInput, GetCardUnreadMovementsUseCaseOkOutput, StringErrorOutput>, GetCardUnreadMovementsUseCase, CardPFMWaiter {
    
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetCardUnreadMovementsUseCaseInput) throws -> UseCaseResponse<GetCardUnreadMovementsUseCaseOkOutput, StringErrorOutput> {
        wait(untilFinished: CardEntity(requestValues.card))
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let userId = globalPosition.userCodeType else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let pfm: PfmHelperProtocol = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        let date = Date().getDateByAdding(days: -89, ignoreHours: true)
        let movements = pfm.getUnreadMovementsFor(userId: userId, date: date, card: CardEntity(requestValues.card))
        return UseCaseResponse.ok(GetCardUnreadMovementsUseCaseOkOutput(newMovements: movements ?? 0))
    }
}
