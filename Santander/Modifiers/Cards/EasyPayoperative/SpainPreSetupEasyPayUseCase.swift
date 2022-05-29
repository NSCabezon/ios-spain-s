//
//  SpainPreSetupEasyPayUseCase.swift
//  Santander
//
//  Created by Hernán Villamil on 9/3/22.
//

import Foundation
import Cards
import SANLegacyLibrary
import CoreFoundationLib

final class SpainPreSetupEasyPayUseCase: UseCase<PreSetupEasyPayUseCaseInput, PreSetupEasyPayUseCaseOkOutput, StringErrorOutput>,
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
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pfm: PfmHelperProtocol = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        guard let userId = globalPosition.userCodeType,
            let today = Calendar.current.startOfDay(for: Date()).getUtcDate(),
            let yesterday = today.getUtcDateByAdding(days: -1)
            else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        let cardTransactions = cardList.reduce([CardTransactionWithCardEntity]()) { (transactions, card) in
            let cardMovements = pfm.getLastMovementsFor(userId: userId, card: card, startDate: yesterday, endDate: today)
            let newTransactions = cardMovements.compactMap { (movement) -> CardTransactionWithCardEntity? in
                guard movement.type == .transaction else {
                    return nil
                }
                
                guard let value = movement.amount?.value,
                    movement.amount?.dto.currency?.currencyType == CoreCurrencyDefault.default else { return nil }
                let doubleValue = Double(truncating: value as NSNumber)
                guard doubleValue < 0 && abs(defaultMinimimAmount) <= abs(doubleValue) else { return nil }
                return CardTransactionWithCardEntity(cardTransactionEntity: movement, cardEntity: card)
            }
            return transactions + newTransactions
        }
        return UseCaseResponse.ok(PreSetupEasyPayUseCaseOkOutput(cardTransactions: cardTransactions))
    }
}
