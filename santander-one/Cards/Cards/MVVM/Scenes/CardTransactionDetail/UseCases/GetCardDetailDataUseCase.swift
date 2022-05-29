//
//  GetCardDetailDataUseCase.swift
//  Cards
//
//  Created by Gloria Cano López on 7/4/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol GetCardDetailDataUseCase {
    func fetchCardDetailDataUseCase(card: CardRepresentable,
                                    transaction: CardTransactionRepresentable) -> AnyPublisher<CardDetailRepresentable, Error>
}

struct DefaultGetCardDetailDataUseCase {
    private let globalPositionRepository: GlobalPositionDataRepository
    private let repository: CardRepository
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        self.globalPositionRepository = dependencies.resolve()
        self.repository = dependencies.resolve()
    }
}

extension DefaultGetCardDetailDataUseCase: GetCardDetailDataUseCase {
    func fetchCardDetailDataUseCase(card: CardRepresentable, transaction: CardTransactionRepresentable) -> AnyPublisher<CardDetailRepresentable, Error> {
        return globalPositionRepository.getGlobalPosition()
            .flatMap { (globalPosition: GlobalPositionDataRepresentable) -> AnyPublisher<CardDetailRepresentable, Error> in
                let userId = globalPosition.clientName
                return loadCardDetail(card: card, userId: userId)
            }
            .eraseToAnyPublisher()
    }
    
}

private extension DefaultGetCardDetailDataUseCase {
    
    func loadCardDetail(card: CardRepresentable, userId: String?) -> AnyPublisher<CardDetailRepresentable, Error> {
        return repository.loadCardDetail(card: card)
            .map { cardDetail in copy(card: cardDetail, userId: userId)}
            .eraseToAnyPublisher()
    }
    
    func copy(card: CardDetailRepresentable, userId: String?) -> CardDetailRepresentable {
        var cardDetail: CardDetailRepresentable
        cardDetail = card
        cardDetail.clientName = userId
        return cardDetail
        
    }
}
