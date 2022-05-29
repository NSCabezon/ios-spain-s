//
//  CardRepository.swift
//  Cards-Cards
//
//  Created by Gloria Cano López on 14/12/21.
//

import Foundation
import OpenCombine

public protocol CardRepository {
    func loadTransactions(card: CardRepresentable, page: PaginationRepresentable?, filter: CardTransactionFiltersRepresentable?)  -> AnyPublisher<CardTransactionsListRepresentable, Error>
    func loadCardDetail(card: CardRepresentable) -> AnyPublisher<CardDetailRepresentable, Error>
    func changeAliasCard(card: CardRepresentable, newAlias: String) -> AnyPublisher<Void, Error>
    func loadCardTransactionLocationsList(card: CardRepresentable) -> AnyPublisher<[CardMovementLocationRepresentable], Never>
    func loadCardTransactionLocationsListByDate(card: CardRepresentable, startDate: Date, endDate: Date) -> AnyPublisher<[CardMovementLocationRepresentable], Never>
    func loadCardSingleMovementLocation(card: CardRepresentable, transaction: CardTransactionRepresentable, transactionDetail: CardTransactionDetailRepresentable?) -> AnyPublisher<CardMovementLocationRepresentable, Error>
    func loadFeesEasyPay(card: CardRepresentable) -> AnyPublisher<FeeDataRepresentable, Error>
    func loadTransactionDetailEasyPay(card: CardRepresentable, cardDetail: CardDetailRepresentable?, transaction: CardTransactionRepresentable, easyPayContract: EasyPayContractTransactionRepresentable?) -> AnyPublisher<EasyPayRepresentable, Error>
    func loadContractMovement(card: CardRepresentable, date: DateFilter?, transaction: CardTransactionRepresentable) -> AnyPublisher<EasyPayContractTransactionListRepresentable, Error>
    func loadCardTransactionDetail(card: CardRepresentable, transaction: CardTransactionRepresentable) -> AnyPublisher<CardTransactionDetailRepresentable, Error>
    func loadEasyPayFees(card: CardRepresentable, numFees: Int, balanceCode: String?, transactionDay: String?) -> AnyPublisher<FeesInfoRepresentable, Error>
}

public extension CardRepository {
    func loadCardSingleMovementLocation(card: CardRepresentable, transaction: CardTransactionRepresentable, transactionDetail: CardTransactionDetailRepresentable?) -> AnyPublisher<CardMovementLocationRepresentable, Error> {
        return Empty().eraseToAnyPublisher()
    }
    
    func loadFeesEasyPay(card: CardRepresentable) -> AnyPublisher<FeeDataRepresentable, Error> {
        return Empty().eraseToAnyPublisher()
    }
    
    func loadTransactionDetailEasyPay(card: CardRepresentable, cardDetail: CardDetailRepresentable?, transaction: CardTransactionRepresentable, easyPayContract: EasyPayContractTransactionRepresentable?) -> AnyPublisher<EasyPayRepresentable, Error> {
        return Empty().eraseToAnyPublisher()
    }
    
    func loadContractMovement(card: CardRepresentable, date: DateFilter?, transaction: CardTransactionRepresentable) -> AnyPublisher<EasyPayContractTransactionListRepresentable, Error> {
        return Empty().eraseToAnyPublisher()
    }
    
    func loadCardTransactionDetail(card: CardRepresentable, transaction: CardTransactionRepresentable) -> AnyPublisher<CardTransactionDetailRepresentable, Error> {
        return Empty().eraseToAnyPublisher()
    }
    
    func loadEasyPayFees(card: CardRepresentable, numFees: Int, balanceCode: String?, transactionDay: String?) -> AnyPublisher<FeesInfoRepresentable, Error> {
        return Empty().eraseToAnyPublisher()
    }
}
