//
//  CardReactiveDataRepository.swift
//  SANServicesLibrary
//
//  Created by Gloria Cano López on 7/3/22.
//
import Foundation
import CoreDomain
import OpenCombine
import OpenCombineDispatch
import SANLegacyLibrary

public struct CardReactiveDataRepository {
    let cardManager: BSANCardsManager
    
    public init(cardManager: BSANCardsManager) {
        self.cardManager = cardManager
    }
}

extension CardReactiveDataRepository: CardRepository {
    public func loadTransactions(card: CardRepresentable, page: PaginationRepresentable?, filter: CardTransactionFiltersRepresentable?) -> AnyPublisher<CardTransactionsListRepresentable, Error> {
        let paginationDTO = page as? PaginationDTO
        guard let cardDTO = card as? CardDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<CardTransactionsListRepresentable, Error>{ promise in
            Async(queue: .global(qos: .userInitiated)) {
                do {
                    let result = try getCardTransactions(forCard: cardDTO, dateFilter: nil, pagination: paginationDTO)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func loadCardDetail(card: CardRepresentable) -> AnyPublisher<CardDetailRepresentable, Error> {
        guard let cardDTO = card as? CardDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<CardDetailRepresentable, Error> { promise in
            Async(queue: .global(qos: .userInitiated)) {
                do {
                    let result = try getCardDetail(forCard: cardDTO)
                    promise(.success(result))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func changeAliasCard(card: CardRepresentable, newAlias: String) -> AnyPublisher<Void, Error> {
        guard let cardDTO = card as? CardDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future { promise in
            Async(queue: .global(qos: .userInitiated)) {
                do {
                    let _ = try changeAlias(forCard: cardDTO, newAlias: newAlias)
                    promise(.success(()))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

private extension CardReactiveDataRepository {
    func getCardDetail(forCard card: CardDTO) throws -> CardDetailRepresentable {
        let response = try cardManager.getCardDetail(cardDTO: card)
        guard let result = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        return result
    }
    
    func changeAlias(forCard card: CardDTO, newAlias: String) throws -> Void {
        let response = try cardManager.changeCardAlias(cardDTO: card, newAlias: newAlias)
        if !response.isSuccess() {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
    }
    
    func getCardTransactions(forCard card: CardDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> CardTransactionsListRepresentable {
        let response = try cardManager.getCardTransactions(cardDTO: card, pagination: pagination, dateFilter: dateFilter)
        guard let responseData = try response.getResponseData() else {
            throw SomeError(errorDescription: try response.getErrorMessage())
        }
        let pagination: PaginationDTO? = responseData.pagination.endList ? nil : responseData.pagination
        
        struct Result: CardTransactionsListRepresentable {
            var transactions: [CardTransactionRepresentable]
            var pagination: PaginationRepresentable?
        }
        
        return CardResultPage(transactions: responseData.transactionDTOs, pagination: pagination)
    }
}


private extension CardReactiveDataRepository {
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }
    
    struct CardResultPage: CardTransactionsListRepresentable {
        var transactions: [CardTransactionRepresentable]
        var pagination: PaginationRepresentable?
    }
}
