//
//  GetReactivePFMCardTransactionsUseCase.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 1/2/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol GetReactivePFMCardTransactionsUseCase {
    // TODO: Refactor to representables
    func fetchCardTrasactions(for card: CardEntity) -> AnyPublisher<[CardTransactionEntity], Error>
}

final class DefaultGetReactivePFMCardTransactionsUseCase {
    
    private let dependenciesResolver: PFMDependenciesResolver
    
    init(dependenciesResolver: PFMDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension DefaultGetReactivePFMCardTransactionsUseCase: GetReactivePFMCardTransactionsUseCase {
    
    func fetchCardTrasactions(for card: CardEntity) -> AnyPublisher<[CardTransactionEntity], Error> {
        return handler.finishedCardsPublisher
            .first(where: { $0.contains(where: { $0.uniqueIdentifier == card.representable.uniqueIdentifier }) })
            .zip(globalPositionRepository.getGlobalPosition())
            .flatMap({ _, globalPosition in return self.fetchCardPFMTransactions(for: card, userId: globalPosition.userId ?? "") })
            .subscribe(on: Schedulers.global)
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetReactivePFMCardTransactionsUseCase {
    
    var handler: PFMTransactionsHandler {
        return dependenciesResolver.resolve()
    }
    var helper: PfmHelperProtocol {
        return dependenciesResolver.resolve()
    }
    var globalPositionRepository: GlobalPositionDataRepository {
        return dependenciesResolver.resolve()
    }
    
    func fetchCardPFMTransactions(for card: CardEntity, userId: String) -> AnyPublisher<[CardTransactionEntity], Error> {
        return Future { [helper] promise in
            let transactions = helper.getLastMovementsFor(userId: userId, card: card)
            promise(.success(transactions))
        }
        .eraseToAnyPublisher()
    }
}
