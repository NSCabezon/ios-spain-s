//
//  GetTransactionCategoryUseCase.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 23/12/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

class GetTransactionCategoryUseCase: UseCase<TransactionCategoryUseCaseInput, TransactionCategoryUseCaseOkOutPut, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: TransactionCategoryUseCaseInput) throws -> UseCaseResponse<TransactionCategoryUseCaseOkOutPut, StringErrorOutput> {
        let accountsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanAccountsManager()

        let plainDGO = requestValues.dgoNumber.replacingOccurrences(of: "-", with: "")
        let params = TransactionCategorizerInputParams(movementId: plainDGO, movementDescription: requestValues.transactionDescription, amount: requestValues.amount, date: requestValues.date)
        let response = try accountsManager.getAccountTransactionCategory(params: params)
        guard response.isSuccess(), let categoryResponse = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        return .ok(TransactionCategoryUseCaseOkOutPut(category: categoryResponse.category, subcategory: categoryResponse.subcategory))
    }
}

struct TransactionCategoryUseCaseInput {
    let dgoNumber: String
    let transactionDescription: String
    let amount: Decimal
    let date: Date
}

struct TransactionCategoryUseCaseOkOutPut {
    let category: String
    let subcategory: String?
}
