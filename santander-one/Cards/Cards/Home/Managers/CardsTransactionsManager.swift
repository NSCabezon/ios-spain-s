//
//  CardsTransactionsManager.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 05/11/2019.
//

import CoreFoundationLib
import CoreDomain

typealias CardTransactionResult = Result<CardTransactionsListEntity, CardsTransactionsError>
typealias CardTransactionCompletion = (CardTransactionResult) -> Void

enum CardsTransactionsError: Error {
    case empty(String)
    case wsError(String)
}

protocol CardsTransactionsManagerProtocol {
    func loadTransactions(for card: CardEntity, filters: TransactionFiltersEntity?, pagination: PaginationEntity?, completion: @escaping (CardTransactionCompletion))
    func loadPendingCardTransactions(for car: CardEntity, pagination: PaginationEntity?, completion: @escaping (CardTransactionCompletion))
}

class CardsTransactionsManager: CardsTransactionsManagerProtocol {
    private weak var activeFilters: TransactionFiltersEntity?
    private let dependenciesResolver: DependenciesResolver
    private var waitingTransactions: [CardEntity: (CardTransactionCompletion, CardTransactionType)] = [:]
    private let localAppConfig: LocalAppConfig
    
    private var getCardsTransactionsUseCase: GetCardTransactionsUseCase {
        return dependenciesResolver.resolve(for: GetCardTransactionsUseCase.self)
    }
    
    private var getPendingCardTransactions: GetCardPendingTransactionsUseCase {
        return self.dependenciesResolver.resolve(for: GetCardPendingTransactionsUseCase.self)
    }
    
    private var pfmController: PfmControllerProtocol {
        return dependenciesResolver.resolve(for: PfmControllerProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
        self.pfmController.registerPFMSubscriber(with: self)
    }
    
    deinit {
        self.pfmController.removePFMSubscriber(self)
    }
    
    func loadTransactions(for card: CardEntity,
                          filters: TransactionFiltersEntity?,
                          pagination: PaginationEntity?,
                          completion: @escaping (CardTransactionCompletion)) {
        self.activeFilters = filters
        if self.localAppConfig.isEnabledPfm {
            guard pfmController.isPFMCardReady(card: card) else {
                self.waitingTransactions[card] = (completion, .transaction)
                return
            }
        }
        self.loadTransactionsFromUseCase(for: card, filters: filters, pagination: pagination, completion: completion)
    }
    
    func loadPendingCardTransactions(for card: CardEntity,
                                     pagination: PaginationEntity?,
                                     completion: @escaping (CardTransactionCompletion)) {
        if self.localAppConfig.isEnabledPfm {
            guard pfmController.isPFMCardReady(card: card) else {
                self.waitingTransactions[card] = (completion, .pendingTransaction)
                return
            }
        }
        self.loadPendingCardTransactionsFromUseCase(for: card, pagination: pagination, completion: completion)
    }
}

extension CardsTransactionsManager: PfmControllerSubscriber {
    
    func finishedPFM(months: [MonthlyBalanceRepresentable]) {
        // Nothing to do here
    }
    
    func finishedPFMAccount(account: AccountEntity) {
        // Nothing to do here
    }

    func finishedPFMCard(card: CardEntity) {
        guard let (completion, type) = self.waitingTransactions[card] else { return }
        switch type {
        case .transaction:
            self.loadTransactionsFromUseCase(for: card, filters: self.activeFilters, pagination: nil, completion: completion)
        case .pendingTransaction:
            self.loadPendingCardTransactionsFromUseCase(for: card, pagination: nil, completion: completion)
        }
        self.waitingTransactions.removeValue(forKey: card)
    }
}

private extension CardsTransactionsManager {
    
    func loadTransactionsFromUseCase(for card: CardEntity, filters: TransactionFiltersEntity?, pagination: PaginationEntity?, completion: @escaping (CardTransactionCompletion)) {
        UseCaseWrapper(
            with: self.getCardsTransactionsUseCase.setRequestValues(requestValues: GetCardTransactionsUseCaseInput(card: card, filters: filters, pagination: pagination, isEnabledPFM: self.localAppConfig.isEnabledPfm)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { response in
                guard !response.transactionList.transactions.isEmpty else {
                    completion(.failure(.empty("generic_label_emptyNotAvailableMoves")))
                    return
                }
                completion(.success(response.transactionList))
            },
            onError: { [weak self] _ in
                guard let currentOptionalFilter = self?.activeFilters,
                    currentOptionalFilter.actives().count > 0 else {
                        completion(.failure(.wsError("generic_label_emptyNotAvailableMoves")))
                        return
                }
                completion(.failure(.wsError("product_label_emptyError")))
            }
        )
    }
    
    func loadPendingCardTransactionsFromUseCase(for entity: CardEntity,
                                                pagination: PaginationEntity?,
                                                completion: @escaping (CardTransactionCompletion)) {
        let input = GetCardPendingTransactionsUseCaseInput(card: entity, pagination: pagination)
        UseCaseWrapper(
            with: self.getPendingCardTransactions.setRequestValues(requestValues: input),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { response in
                guard !response.transactionList.transactions.isEmpty else {
                    completion(.failure(.empty("cardsMovPending_empty_noTransaction")))
                    return
                }
                completion(.success(response.transactionList))
            },
            onError: { _ in
                completion(.failure(.wsError("cardsMovPending_empty_noTransaction")))
            }
        )
    }
}
