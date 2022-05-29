//
//  EasyPayContractTransactionEntity.swift
//  Models
//
//  Created by David Gálvez Alonso on 05/05/2020.
//

import SANLegacyLibrary

public struct EasyPayContractTransactionEntity: CardTransactionPkProtocol {
    public let dto: EasyPayContractTransactionDTO
    
    public init(_ dto: EasyPayContractTransactionDTO) {
        self.dto = dto
    }
    public var operationDate: Date? {
        return dto.operationDate
    }
    public var amount: AmountEntity? {
        guard let amount = dto.amountDTO else { return nil }
        return AmountEntity(amount)
    }
    public var transactionDay: String? {
        return dto.transactionDay
    }
    public var balanceCode: String? {
        return dto.balanceCode
    }
}

public protocol CardTransactionPkProtocol {
    var amount: AmountEntity? { get }
    var operationDate: Date? { get }
    var transactionDay: String? { get }
}

public extension CardTransactionPkProtocol {
    var pk: String {
        var pkDescription = ""
        if let date = operationDate?.description {
            pkDescription += date
        }
        let formattedValue: String
        if let value = amount?.dto.value {
            let decimal = NSDecimalNumber(decimal: abs(value))
            formattedValue = NumberFormatter().string(from: decimal) ?? "0"
        } else {
            formattedValue = "0"
        }
        pkDescription += formattedValue
        if let currencyName = amount?.dto.currency?.currencyName {
            pkDescription += currencyName
        }
        if let transactionDay = transactionDay {
            pkDescription += transactionDay
        }
        return pkDescription
    }
}
