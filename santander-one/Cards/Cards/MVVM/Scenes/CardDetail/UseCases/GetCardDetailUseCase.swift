//
//  CardDetailUseCase.swift
//  Cards
//
//  Created by Gloria Cano López on 17/2/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetCardDetailUseCase {
    func fetchCardDetail(card: CardRepresentable) -> AnyPublisher<CardDetailRepresentable, Error>
    func fetchCardGlobalPosition(card: CardRepresentable) -> AnyPublisher<CardRepresentable?, Never>
}

struct DefaultGetCardDetailUseCase: GetCardDetailUseCase {
    private let repository: CardRepository
    private let globalPositionRepository: GlobalPositionDataRepository
    private var card: CardRepresentable?
    
    init(dependencies: CardDetailDependenciesResolver) {
        repository = dependencies.external.resolve()
        globalPositionRepository = dependencies.external.resolve()
    }
}

extension DefaultGetCardDetailUseCase {
    func fetchCardDetail(card: CardRepresentable) -> AnyPublisher<CardDetailRepresentable, Error> {
        return repository
            .loadCardDetail(card: card)
            .eraseToAnyPublisher()
    }
    
    func fetchCardGlobalPosition(card: CardRepresentable) -> AnyPublisher<CardRepresentable?, Never> {
        return globalPositionRepository.getGlobalPosition()
            .map { globalPosition in
               globalPosition.cardRepresentables.first(where: { $0.uniqueIdentifier == card.uniqueIdentifier})
            }
            .eraseToAnyPublisher()
    }
}
