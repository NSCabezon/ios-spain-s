//
//  ExpensesIncomeCategoriesUseCase.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 11/6/21.
//

import CoreFoundationLib

final class ExpensesIncomeCategoriesUseCase: UseCase<Void, ExpensesIncomeCategoriesUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ExpensesIncomeCategoriesUseCaseOkOutput, StringErrorOutput> {
        return .ok(ExpensesIncomeCategoriesUseCaseOkOutput())
    }
}

struct ExpensesIncomeCategoriesUseCaseOkOutput {

}
