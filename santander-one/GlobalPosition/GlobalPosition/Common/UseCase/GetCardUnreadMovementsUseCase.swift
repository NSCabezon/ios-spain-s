//
//  GetCardUnreadMovementsUseCase.swift
//  GlobalPosition
//
//  Created by alvola on 31/10/2019.
//

import CoreFoundationLib
import CoreDomain

public protocol GetCardUnreadMovementsUseCase: UseCase<GetCardUnreadMovementsUseCaseInput, GetCardUnreadMovementsUseCaseOkOutput, StringErrorOutput> {}

final class DefaultGetCardUnreadMovementsUseCase: UseCase<GetCardUnreadMovementsUseCaseInput, GetCardUnreadMovementsUseCaseOkOutput, StringErrorOutput>, GetCardUnreadMovementsUseCase {
    override func executeUseCase(requestValues: GetCardUnreadMovementsUseCaseInput) throws -> UseCaseResponse<GetCardUnreadMovementsUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetCardUnreadMovementsUseCaseOkOutput(newMovements: 0))
    }
}

public struct GetCardUnreadMovementsUseCaseInput {
    public let card: CardRepresentable
    
    public init(card: CardRepresentable) {
        self.card = card
    }
}

public struct GetCardUnreadMovementsUseCaseOkOutput {
    public let newMovements: Int
    
    public init(newMovements: Int) {
        self.newMovements = newMovements
    }
}
