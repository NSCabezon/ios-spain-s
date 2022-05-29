//
//  ConfirmEasyPayUseCase.swift
//  Cards
//
//  Created by alvola on 14/12/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

final class ConfirmEasyPayUseCase: UseCase<ConfirmEasyPayUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: ConfirmEasyPayUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let cardDto = requestValues.card.dto
        let easyPayContractTransactionDto = requestValues.easyPayContractTransaction.dto
        let parameters = BuyFeesParameters(numFees: requestValues.numFees,
                                           balanceCode: easyPayContractTransactionDto.balanceCode ?? "",
                                           transactionDay: easyPayContractTransactionDto.transactionDay ?? "")
        let response = try provider.getBsanCardsManager().confirmationEasyPay(input: parameters, card: cardDto)
        if response.isSuccess() {
            return UseCaseResponse.ok()
        } else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
    }
}

struct ConfirmEasyPayUseCaseInput {
    let card: CardEntity
    let numFees: Int
    let easyPayContractTransaction: EasyPayContractTransactionEntity
}
