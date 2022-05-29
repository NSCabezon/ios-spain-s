//
//  OneExchangeRateAmountViewModel.swift
//  CoreFoundationLib
//
//  Created by Angel Abad Perez on 25/4/22.
//

import CoreDomain

public struct OneExchangeRateAmountViewModel {
    public var originAmount: OneExchangeRateAmount
    public var type: OneExchangeRateAmountViewType
    public let alert: OneExchangeRateAmountAlert?
    public let accessibilitySuffix: String
    
    public init(originAmount: OneExchangeRateAmount,
                type: OneExchangeRateAmountViewType,
                alert: OneExchangeRateAmountAlert? = nil,
                accessibilitySuffix: String = "") {
        self.originAmount = originAmount
        self.type = type
        self.alert = alert
        self.accessibilitySuffix = accessibilitySuffix
    }
}

public enum OneExchangeRateAmountViewType {
    case noExchange
    case exchange(destinationAmount: OneExchangeRateAmount)
    
    public mutating func setDestinationAmount(_ newAmount: AmountRepresentable) {
        switch self {
        case .exchange(var destinationAmount):
            destinationAmount.amount = newAmount
            self = .exchange(destinationAmount: destinationAmount)
        case .noExchange:
            self = .noExchange
        }
    }
}

public struct OneExchangeRateAmount {
    public var amount: AmountRepresentable
    public let buyRate: AmountRepresentable
    public let sellRate: AmountRepresentable
    public let currencySelector: UIView?
    
    public init(amount: AmountRepresentable,
                buyRate: AmountRepresentable,
                sellRate: AmountRepresentable,
                currencySelector: UIView? = nil) {
        self.amount = amount
        self.buyRate = buyRate
        self.sellRate = sellRate
        self.currencySelector = currencySelector
    }
    
    public func hasSameAmountAndRatesCurrencies() -> Bool {
        let amountCurrencyCode = amount.currencyRepresentable?.currencyCode
        return amountCurrencyCode == buyRate.currencyRepresentable?.currencyCode && amountCurrencyCode == sellRate.currencyRepresentable?.currencyCode
    }
}

public struct OneExchangeRateAmountAlert {
    public let iconName: String
    public let titleKey: String
    
    public init(iconName: String,
                titleKey: String) {
        self.iconName = iconName
        self.titleKey = titleKey
    }
}
