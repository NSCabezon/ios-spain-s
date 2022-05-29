//
//  CardSelectorListUseCase.swift
//  Cards
//
//  Created by Ignacio González Miró on 10/6/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public final class CardSelectorListUseCase: UseCase<CardSelectorListUseCaseInput, CardSelectorListUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: CardSelectorListUseCaseInput) throws -> UseCaseResponse<CardSelectorListUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve()
        let allowedTypes = requestValues.allowedTypes
        let cardList = globalPosition.cards.visibles().filter {
            return !$0.isDisabled && allowedTypes.contains($0.cardType) && $0.isCardContractHolder
        }
        return .ok(CardSelectorListUseCaseOkOutput(cardSelectorList: cardList))
    }
}

public struct CardSelectorListUseCaseInput {
    let baseUrl: String
    let allowedTypes: [CardDOType]
}

public struct CardSelectorListUseCaseOkOutput {
    let cardSelectorList: [CardEntity]
}
