//
//  MockCardRepository.swift
//  CoreTestData
//
//  Created by Gloria Cano López on 10/1/22.
//

import Foundation
import CoreDomain
import OpenCombine
import OpenCombineDispatch
import CoreFoundationLib

public final class MockCardRepository: CardRepository {
    var transactions: [CardTransactionRepresentable]
    var carDetail: CardDetailRepresentable
    var transactionDetail: CardTransactionDetailRepresentable
    var locationsForShoppingMap: [CardMovementLocationRepresentable]
    var easyPayFees: FeeDataRepresentable
    let contractList: EasyPayContractTransactionListRepresentable
    let easyPay: EasyPayRepresentable
    let feesInfo: FeesInfoRepresentable
    
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }
    
    public init(mockDataInjector: MockDataInjector) {
        transactions = mockDataInjector
            .mockDataProvider
            .cardsData
            .getCardTransactionsList
            .transactionDTOs
        
        carDetail = mockDataInjector
            .mockDataProvider
            .cardsData
            .getCardDetail
        
        locationsForShoppingMap = mockDataInjector
            .mockDataProvider
            .cardsData
            .getCardMovementLocationListDTO
            .transactions
        
        easyPayFees = mockDataInjector
            .mockDataProvider
            .cardsData
            .getCardTransactionFeesEasyPay
        
        contractList = mockDataInjector
            .mockDataProvider
            .cardsData
            .getTransactionsEasyPayContract
        
        easyPay = mockDataInjector
            .mockDataProvider
            .cardsData
            .getTransactionDetailEasyPay
        
        transactionDetail = mockDataInjector
            .mockDataProvider
            .cardsData
            .getTransactionDetail
        
        feesInfo = mockDataInjector
            .mockDataProvider
            .cardsData
            .getFeesInfo
    }
    
    
    public func loadTransactions(card: CardRepresentable, page: PaginationRepresentable?, filter: CardTransactionFiltersRepresentable?) -> AnyPublisher<CardTransactionsListRepresentable, Error> {
//        guard card.appIdentifier != "fail" else {
//            return Fail(error: SomeError(errorDescription: "generic_label_emptyNotAvailableMoves")).eraseToAnyPublisher()
//        }
        return Fail(error: SomeError(errorDescription: "generic_label_emptyNotAvailableMoves")).eraseToAnyPublisher()
//        let nextPage = card.appIdentifier == "pagining" ? CardNextPage() : nil
//        return Just(CardResultPage(transactions: transactions, pagination: nextPage))
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
    }
    
    public func loadCardDetail(card: CardRepresentable) -> AnyPublisher<CardDetailRepresentable, Error> {
        return Just(carDetail)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func changeAliasCard(card: CardRepresentable, newAlias: String) -> AnyPublisher<Void, Error> {
        return Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

    }
    
    public func loadCardTransactionLocationsList(card: CardRepresentable) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        return Just(locationsForShoppingMap)
            .eraseToAnyPublisher()
    }
    
    public func loadCardTransactionLocationsListByDate(card: CardRepresentable, startDate: Date, endDate: Date) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        return Just(Array(locationsForShoppingMap.prefix(3)))
            .eraseToAnyPublisher()
    }
    
    public func loadCardSingleMovementLocation(card: CardRepresentable, transaction: CardTransactionRepresentable, transactionDetail: CardTransactionDetailRepresentable?) -> AnyPublisher<CardMovementLocationRepresentable, Error> {
        guard let movement = locationsForShoppingMap.first else  {
            return Fail(error: SomeError(errorDescription: "generic_label_emptyNotAvailableMoves")).eraseToAnyPublisher()
        }
        return Just(movement)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadFeesEasyPay(card: CardRepresentable) -> AnyPublisher<FeeDataRepresentable, Error> {
        return Just(easyPayFees)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadTransactionDetailEasyPay(card: CardRepresentable, cardDetail: CardDetailRepresentable?, transaction: CardTransactionRepresentable, easyPayContract: EasyPayContractTransactionRepresentable?) -> AnyPublisher<EasyPayRepresentable, Error> {
        return Just(easyPay)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadContractMovement(card: CardRepresentable, date: DateFilter?, transaction: CardTransactionRepresentable) -> AnyPublisher<EasyPayContractTransactionListRepresentable, Error> {
        return Just(contractList)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadCardTransactionDetail(card: CardRepresentable, transaction: CardTransactionRepresentable) -> AnyPublisher<CardTransactionDetailRepresentable, Error> {
        return Just(transactionDetail)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadEasyPayFees(card: CardRepresentable, numFees: Int, balanceCode: String?, transactionDay: String?) -> AnyPublisher<FeesInfoRepresentable, Error> {
        return Just(feesInfo)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}

struct CardResultPage: CardTransactionsListRepresentable {
    var transactions: [CardTransactionRepresentable]
    var pagination: PaginationRepresentable?
}

struct CardNextPage: PaginationRepresentable {}
