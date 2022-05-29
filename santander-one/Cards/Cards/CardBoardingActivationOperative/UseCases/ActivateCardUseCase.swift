//
//  ActivateCardUseCase.swift
//  Cards
//
//  Created by Gabriel Tondin on 06/05/2021.
//

import CoreFoundationLib

public protocol ActivateCardUseCaseProtocol: UseCase<ActivateCardUseCaseInput, Void, StringErrorOutput> { }

public struct ActivateCardUseCaseInput {
    public let selectedCard: CardEntity
    
    public init(selectedCard: CardEntity) {
        self.selectedCard = selectedCard
    }
}
