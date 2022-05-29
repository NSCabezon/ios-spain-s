//
//  GetFinancingCardsDeeplinkUseCase.swift
//  RetailClean
//
//  Created by Cristobal Ramos Laina on 09/07/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib


class GetFinancingCardsDeeplinkUseCase: UseCase<Void, GetFinancingCardsDeeplinkUseCaseOkOutput, StringErrorOutput> {

    private let appConfigRepository: AppConfigRepository
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver, appConfigRepository: AppConfigRepository) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigRepository = appConfigRepository
    }
    
    private func existsCreditCard(card: CardEntity) -> Bool {
        return card.isCreditCard
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFinancingCardsDeeplinkUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let cards: [CardEntity] = globalPosition.cards.visibles()
        let existCreditCard = cards.first { existsCreditCard(card: $0) }
        if existCreditCard != nil && appConfigRepository.getBool("enableFinancingZone") == true {
            return UseCaseResponse.ok(GetFinancingCardsDeeplinkUseCaseOkOutput(deeplinkCardsEnabled: true))
        }
        return UseCaseResponse.ok(GetFinancingCardsDeeplinkUseCaseOkOutput(deeplinkCardsEnabled: false))
    }
}

struct GetFinancingCardsDeeplinkUseCaseOkOutput {
    let deeplinkCardsEnabled: Bool
}
