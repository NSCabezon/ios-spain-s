//
//  SpainGetCardExpensesCalculationUseCase.swift
//  Santander
//
//  Created by Gloria Cano López on 17/3/22.
//

import Foundation
import CoreFoundationLib
import Cards
import CoreDomain
import OpenCombine
import SANLegacyLibrary

struct SpainGetCardsExpensesCalculationUseCase {
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
}

extension SpainGetCardsExpensesCalculationUseCase: GetCardsExpensesCalculationUseCase {
    func fetchExpensesCalculationPublisher(card: CardRepresentable) -> AnyPublisher<AmountRepresentable, Never> {
        return Just(getExpenses(card: card))
                    .eraseToAnyPublisher()
    }
    
}

private extension SpainGetCardsExpensesCalculationUseCase {
    func getExpenses(card: CardRepresentable) -> AmountRepresentable {
        let userId = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self).userCodeType ?? ""
        let selectedCard = CardEntity(card)
        let expenses = pfmHelper.cardExpensesCalculationTransaction(userId: userId, card: selectedCard)
        let defaultCurrency: CurrencyType = CoreCurrencyDefault.default
        let amount = AmountDTO(value: expenses.value ?? 0, currency: expenses.dto.currency ?? .create(defaultCurrency))
        return amount
    }
}
