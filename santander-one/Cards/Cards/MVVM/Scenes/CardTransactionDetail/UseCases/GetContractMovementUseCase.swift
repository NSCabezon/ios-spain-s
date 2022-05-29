//
//  GetContractMovementUseCase.swift
//  Cards
//
//  Created by Gloria Cano López on 6/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetContractMovementUseCase {
    func fetchContractMovement(card: CardRepresentable,
                               transaction: CardTransactionRepresentable) -> AnyPublisher<EasyPayContractTransactionRepresentable?, Error>
    
}

struct DefaultGetContractMovementUseCase {
    private let repository: CardRepository
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        repository = dependencies.resolve()
    }
}

extension DefaultGetContractMovementUseCase: GetContractMovementUseCase {
    func fetchContractMovement(card: CardRepresentable, transaction: CardTransactionRepresentable) -> AnyPublisher<EasyPayContractTransactionRepresentable?, Error> {
        var dateFilterContractMovement: DateFilter?
        if let operationDate = transaction.operationDate, let annotationDate = transaction.annotationDate {
            dateFilterContractMovement = DateFilter(from: operationDate, to: annotationDate)
        }
        return repository.loadContractMovement(card: card, date: dateFilterContractMovement, transaction: transaction)
            .map { contract in
                return searchMovementContract(contract: contract, transaction: transaction)
            }
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetContractMovementUseCase {
    func searchMovementContract(contract: EasyPayContractTransactionListRepresentable, transaction: CardTransactionRepresentable) -> EasyPayContractTransactionRepresentable? {
        let easyPayContractTransactions = contract.transactions ?? []
        let pkOrigin = getpkOriginForTransaction(transaction)
        _ = easyPayContractTransactions.first(where: { transaction -> Bool in
            return getpkOriginForContract(transaction) == pkOrigin
        })
        return nil
    }
    
    func getpkOriginForTransaction(_ transaction: CardTransactionRepresentable) -> String {
        var pkDescription = ""
        if let date = transaction.operationDate?.description {
            pkDescription += date
        }
        let formattedValue: String
        if let amountRepresentable = transaction.amountRepresentable,
           let value = AmountEntity(amountRepresentable).dto.value {
            let decimal = NSDecimalNumber(decimal: abs(value))
            formattedValue = NumberFormatter().string(from: decimal) ?? "0"
        } else {
            formattedValue = "0"
        }
        pkDescription += formattedValue
        if let amountRepresentable = transaction.amountRepresentable,
           let currencyName = AmountEntity(amountRepresentable).dto.currency?.currencyName {
            pkDescription += currencyName
        }
        if let transactionDay = transaction.transactionDay {
            pkDescription += transactionDay
        }
        return pkDescription
    }
    
    func getpkOriginForContract(_ contract: EasyPayContractTransactionRepresentable) -> String {
        var pkDescription = ""
        if let date = contract.operationDate?.description {
            pkDescription += date
        }
        let formattedValue: String
        if let amountRepresentable = contract.amount,
           let value = AmountEntity(amountRepresentable).dto.value {
            let decimal = NSDecimalNumber(decimal: abs(value))
            formattedValue = NumberFormatter().string(from: decimal) ?? "0"
        } else {
            formattedValue = "0"
        }
        pkDescription += formattedValue
        if let amountRepresentable = contract.amount,
           let currencyName = AmountEntity(amountRepresentable).dto.currency?.currencyName {
            pkDescription += currencyName
        }
        if let transactionDay = contract.transactionDay {
            pkDescription += transactionDay
        }
        return pkDescription
    }
}
