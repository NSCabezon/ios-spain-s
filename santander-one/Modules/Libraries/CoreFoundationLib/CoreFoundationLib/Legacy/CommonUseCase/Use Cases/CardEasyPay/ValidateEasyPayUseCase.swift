//
//  ValidateEasyPayUseCase.swift
//  Cards
//
//  Created by David Gálvez Alonso on 06/05/2020.
//

import SANLegacyLibrary

public class ValidateEasyPayUseCase: UseCase<ValidateEasyPayUseCaseInput, ValidateEasyPayUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: ValidateEasyPayUseCaseInput) throws -> UseCaseResponse<ValidateEasyPayUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        let cardDto = requestValues.card.dto
        let cardTransactionDto = requestValues.cardTransaction.dto
        let feeDataDto = requestValues.feeData.dto
        let numFeesSelected = requestValues.numFeesSelected
        let balanceCode = requestValues.balanceCode
        let movementIndex = requestValues.movementIndex
        let response = try cardsManager.getAmortizationEasyPay(cardDTO: cardDto, cardTransactionDTO: cardTransactionDto, feeDataDTO: feeDataDto, numFeesSelected: numFeesSelected, balanceCode: balanceCode, movementIndex: movementIndex)
        if response.isSuccess(), let data = try response.getResponseData() {
            let easyPayAmortization = EasyPayAmortizationEntity(data)
            return UseCaseResponse.ok(ValidateEasyPayUseCaseOkOutput(easyPayAmortization: easyPayAmortization))
        } else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
    }
}

public struct ValidateEasyPayUseCaseInput {
    let card: CardEntity
    let cardTransaction: CardTransactionEntity
    let feeData: FeeDataEntity
    let numFeesSelected: String
    let balanceCode: Int
    let movementIndex: Int
    
    public init(card: CardEntity,
                cardTransaction: CardTransactionEntity,
                feeData: FeeDataEntity,
                numFeesSelected: String,
                balanceCode: Int,
                movementIndex: Int) {
        self.card = card
        self.cardTransaction = cardTransaction
        self.feeData = feeData
        self.numFeesSelected = numFeesSelected
        self.balanceCode = balanceCode
        self.movementIndex = movementIndex
    }
}

public struct ValidateEasyPayUseCaseOkOutput {
    public let easyPayAmortization: EasyPayAmortizationEntity
}
