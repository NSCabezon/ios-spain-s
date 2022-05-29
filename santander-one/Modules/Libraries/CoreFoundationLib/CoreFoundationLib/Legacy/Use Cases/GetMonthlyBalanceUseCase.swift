//
//  GetMonthlyBalanceUseCase.swift
//  User
//
//  Created by José Carlos Estela Anguita on 3/2/22.
//

import Foundation
import CoreDomain

public struct GetMonthlyBalanceUseCaseOkOutput {
    public let data: [MonthlyBalanceRepresentable]
    
    public init(data: [MonthlyBalanceRepresentable]) {
        self.data = data
    }
}

public protocol GetMonthlyBalanceUseCase: UseCase<Void, GetMonthlyBalanceUseCaseOkOutput, StringErrorOutput> {}

public final class DefaultGetMonthlyBalanceUseCase: UseCase<Void, GetMonthlyBalanceUseCaseOkOutput, StringErrorOutput>, GetMonthlyBalanceUseCase {
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetMonthlyBalanceUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetMonthlyBalanceUseCaseOkOutput(data: []))
    }
}

public struct DefaultMonthlyBalance: MonthlyBalanceRepresentable {
    
    public let date: Date
    public let expense: Decimal
    public let income: Decimal
    
    public init(date: Date, expense: Decimal, income: Decimal) {
        self.date = date
        self.expense = expense
        self.income = income
    }
}
