//
//  GetCalculatedExpensesUseCase.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/18/19.
//

import SANLegacyLibrary
import CoreFoundationLib

class GetCardExpensesCalculationUseCase: UseCase<GetCardExpensesCalculationUseCaseInput, GetCardExpensesCalculationUseCaseOkOutput, StringErrorOutput> {

    private let dependenciesResolver: DependenciesResolver
    private var provider: BSANManagersProvider {
        return dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    private var pfmHelper: PfmHelperProtocol {
        return dependenciesResolver.resolve(for: PfmHelperProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetCardExpensesCalculationUseCaseInput) throws -> UseCaseResponse<GetCardExpensesCalculationUseCaseOkOutput, StringErrorOutput> {
        let userId = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self).userCodeType ?? ""
        let expenses = pfmHelper.cardExpensesCalculationTransaction(userId: userId, card: requestValues.card)
        return UseCaseResponse.ok(GetCardExpensesCalculationUseCaseOkOutput(expenses: expenses))
    }
}

struct GetCardExpensesCalculationUseCaseInput {
    let card: CardEntity
}

struct GetCardExpensesCalculationUseCaseOkOutput {
    let expenses: AmountEntity
}
