//
//  PreSetupEasyPayUseCase.swift
//  Cards
//
//  Created by alvola on 01/12/2020.
//

import SANLegacyLibrary
import CoreFoundationLib

public protocol PreSetupEasyPayUseCase: UseCase<PreSetupEasyPayUseCaseInput, PreSetupEasyPayUseCaseOkOutput, StringErrorOutput> {}

final class DefaultPreSetupEasyPayUseCase: UseCase<PreSetupEasyPayUseCaseInput, PreSetupEasyPayUseCaseOkOutput, StringErrorOutput>,
                                           PreSetupEasyPayUseCase {
    private let dependenciesResolver: DependenciesResolver
    private let defaultMinimimAmount = Double(60)
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreSetupEasyPayUseCaseInput) throws -> UseCaseResponse<PreSetupEasyPayUseCaseOkOutput, StringErrorOutput> {
        if requestValues.isProductSelected {
             return UseCaseResponse.ok(PreSetupEasyPayUseCaseOkOutput(cardTransactions: []))
        } else {
            return try getCardTransactions()
        }
    }
    
    private func getCardTransactions() throws ->  UseCaseResponse<PreSetupEasyPayUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve()
        let cardList = globalPosition.cards.visibles().filter {
            return $0.isCreditCard && $0.isCardContractHolder && !$0.isDisabled
        }
        if cardList.isEmpty {
            return UseCaseResponse.ok(PreSetupEasyPayUseCaseOkOutput(cardTransactions: []))
        } else {
            return try getCardMovements(cardList: cardList)
        }
    }
    
    private func getCardMovements(cardList: [CardEntity]) throws ->  UseCaseResponse<PreSetupEasyPayUseCaseOkOutput, StringErrorOutput> {
        let cardTransactions = cardList.reduce([CardTransactionWithCardEntity]()) { (transactions, _) in
            return transactions
        }
        return UseCaseResponse.ok(PreSetupEasyPayUseCaseOkOutput(cardTransactions: cardTransactions))
    }
}

public struct PreSetupEasyPayUseCaseInput {
    public let isProductSelected: Bool
}

public struct PreSetupEasyPayUseCaseOkOutput {
    public let cardTransactions: [CardTransactionWithCardEntity]
    
    public init(cardTransactions: [CardTransactionWithCardEntity]) {
        self.cardTransactions = cardTransactions
    }
}
