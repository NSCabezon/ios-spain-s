//
//  WhatNewDataManager.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 31/07/2020.
//

import CoreFoundationLib

final class WhatsNewDataManager {
    private var dependenciesResolver: DependenciesResolver
    private var lastMovementViewModel: WhatsNewLastMovementsViewModel?
    
    private var setReadCardTransactionsUseCase: SetReadCardTransactionsUseCase {
        return dependenciesResolver.resolve(for: SetReadCardTransactionsUseCase.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var setReadAccountTransactionsUseCase: SetReadAccountTransactionsUseCase {
        return self.dependenciesResolver.resolve(for: SetReadAccountTransactionsUseCase.self)
    }
    
    init(resolver: DependenciesResolver) {
        self.dependenciesResolver = resolver
    }
    
    public func setViewModel(_ viewModel: WhatsNewLastMovementsViewModel) {
        self.lastMovementViewModel = viewModel
    }
    
    public func setReadMovementsForItem(_ item: UnreadMovementItem) {
        switch item.type {
        case .account:
            guard let transaction = lastMovementViewModel?.accountTransactionFromItem(item, isFractionable: item.isFractionable),
                  let entity = transaction.accountTransactionsWithAccountEntity?.accountEntity else {
                return
            }
            markAccountMovementsRead(accountEntity: entity)
        case .card:
            guard let transaction = lastMovementViewModel?.cardTransactionFromItem(item, isFractionable: item.isFractionable),
                  let entity = transaction.cardTransactionsWithAccountEntity?.cardEntity else {
                return
            }
            markCardMovementsRead(cardEntity: entity)
        }
    }
    
    public func setReadAllForCardEntity(_ entity: CardEntity) {
        markCardMovementsRead(cardEntity: entity)
    }
    
    public func setReadAllForAccountEntity(_ entity: AccountEntity) {
        markAccountMovementsRead(accountEntity: entity)
    }
}

private extension WhatsNewDataManager {
    func markCardMovementsRead(cardEntity: CardEntity) {
        UseCaseWrapper(with: self.setReadCardTransactionsUseCase.setRequestValues(requestValues: SetReadCardTransactionsUseCaseInput(card: cardEntity)), useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self)
        )
    }
    
    func markAccountMovementsRead(accountEntity: AccountEntity) {
        let useCaseInput = SetReadAccountTransactionsUseCaseInput(account: accountEntity)
        UseCaseWrapper(with:
            self.setReadAccountTransactionsUseCase.setRequestValues(requestValues: useCaseInput),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self)
        )
    }
}
