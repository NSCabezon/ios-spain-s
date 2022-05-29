//
//  InternalTransferOperativeData.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 15/2/22.
//

import CoreFoundationLib
import CoreDomain

public final class InternalTransferOperativeData {
    public var originAccountsVisibles: [AccountRepresentable] = []
    public var originAccountsNotVisibles: [AccountRepresentable] = []
    public var destinationAccountsVisibles: [AccountRepresentable] = []
    public var destinationAccountsNotVisibles: [AccountRepresentable] = []
    public var originAccount: AccountRepresentable?
    public var destinationAccount: AccountRepresentable?
    public var description: String?
    public var issueDate: Date = Date()
    public var amount: AmountRepresentable?
    public var receiveAmount: AmountRepresentable?
    public var transferType: InternalTransferType?
    
    public func isSameCurrency() -> Bool {
        guard let originType = originAccount?.currencyRepresentable?.currencyType else { return false }
        guard let destinationType = destinationAccount?.currencyRepresentable?.currencyType else { return false }
        return originType == destinationType
    }
    
    public func containsCurrency(type: CurrencyType) -> Bool {
        let originType = originAccount?.currencyRepresentable?.currencyType
        let destinationType = destinationAccount?.currencyRepresentable?.currencyType
        return type == originType || type == destinationType
    }
}

public struct InternalTransferExchangeType {
    var originCurrency: CurrencyRepresentable
    var destinationCurrency: CurrencyRepresentable
    var rate: Decimal?

    func conversionRate(from currency: CurrencyRepresentable) -> Decimal {
        guard let _rate = self.rate else { return 0 }
        return currency.currencyType == originCurrency.currencyType ? _rate : 1/_rate
    }
}

public enum InternalTransferType {
    case noExchange
    case simpleExchange(sellExchange: InternalTransferExchangeType)
    case doubleExchange(sellExchange: InternalTransferExchangeType, buyExchange: InternalTransferExchangeType)

    static func exchangeRateString(exchangeType: InternalTransferExchangeType) -> String {
        let rate = exchangeType.rate?.description ?? "-"
        return "1 \(exchangeType.originCurrency.currencyName) = \(rate) \(exchangeType.destinationCurrency.currencyName)"
    }
}
