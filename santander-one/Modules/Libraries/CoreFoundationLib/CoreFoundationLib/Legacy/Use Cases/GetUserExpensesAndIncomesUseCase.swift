//
//  GetUserExpensesAndIncomesUseCase.swift
//  User
//
//  Created by José Carlos Estela Anguita on 3/2/22.
//

import Foundation

public protocol UserExpensesAndIncomes {
    var date: Date { get }
    var expense: Decimal { get }
    var income: Decimal { get }
}

public struct GetUserExpensesAndIncomesUseCaseOkOutput {
    public let data: [UserExpensesAndIncomes]
    
    public init(data: [UserExpensesAndIncomes]) {
        self.data = data
    }
}

public protocol GetUserExpensesAndIncomesUseCase: UseCase<Void, GetUserExpensesAndIncomesUseCaseOkOutput, StringErrorOutput> {}

final class DefaultGetUserExpensesAndIncomesUseCase: UseCase<Void, GetUserExpensesAndIncomesUseCaseOkOutput, StringErrorOutput>, GetUserExpensesAndIncomesUseCase {
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserExpensesAndIncomesUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetUserExpensesAndIncomesUseCaseOkOutput(data: []))
    }
}
