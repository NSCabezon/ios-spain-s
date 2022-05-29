//
//  GetAccountUnreadMovementsUseCase.swift
//  GlobalPosition
//
//  Created by alvola on 31/10/2019.
//

import CoreFoundationLib
import CoreDomain

public protocol GetAccountUnreadMovementsUseCase: UseCase<GetAccountUnreadMovementsUseCaseInput, GetAccountUnreadMovementsUseCaseOkOutput, StringErrorOutput> {}

final class DefaultGetAccountUnreadMovementsUseCase: UseCase<GetAccountUnreadMovementsUseCaseInput, GetAccountUnreadMovementsUseCaseOkOutput, StringErrorOutput>, GetAccountUnreadMovementsUseCase {
    override func executeUseCase(requestValues: GetAccountUnreadMovementsUseCaseInput) throws -> UseCaseResponse<GetAccountUnreadMovementsUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetAccountUnreadMovementsUseCaseOkOutput(newMovements: 0))
    }
}

public struct GetAccountUnreadMovementsUseCaseInput {
    public let account: AccountRepresentable
    
    public init(account: AccountRepresentable) {
        self.account = account
    }
}

public struct GetAccountUnreadMovementsUseCaseOkOutput {
    public let newMovements: Int
    
    public init(newMovements: Int) {
        self.newMovements = newMovements
    }
}
