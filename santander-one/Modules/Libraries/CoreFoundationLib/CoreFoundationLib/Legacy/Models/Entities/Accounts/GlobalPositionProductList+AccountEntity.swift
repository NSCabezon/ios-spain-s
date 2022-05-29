//
//  GlobalPositionProductList+AccountEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 07/11/2019.
//

import Foundation

extension GlobalPositionProductList where Product == AccountEntity {
    
    public func totalCounterValueWithoutCreditAccounts(accountDescriptors: [AccountDescriptorEntity], useAvailableBalance: Bool) -> Decimal {
        return visibles().compactMap({accountTotalValue($0, accountDescriptors: accountDescriptors, counter: true, credit: false, useAvailableBalance: useAvailableBalance)}).reduce(0, +)
    }
    
    public func totalValueWithoutCreditAccounts(accountDescriptors: [AccountDescriptorEntity], useAvailableBalance: Bool) -> Decimal? {
        let values = visibles().map({accountTotalValue($0, accountDescriptors: accountDescriptors, counter: false, credit: false, useAvailableBalance: useAvailableBalance)})
        guard !values.contains(nil) else { return nil }
        return values.compactMap({$0}).reduce(0, +)
    }
    
    public func totalValueWithoutCreditAccountsIgnoringCounter(_ accountDescriptors: [AccountDescriptorEntity], useAvailableBalance: Bool) -> Decimal {
        let values = visibles().map({accountTotalValue($0, accountDescriptors: accountDescriptors, counter: false, credit: false, useAvailableBalance: useAvailableBalance)})
        return values.compactMap({$0}).reduce(0, +)
    }
    
    public func totalCounterValueFromCreditAccounts(accountDescriptors: [AccountDescriptorEntity], useAvailableBalance: Bool) -> Decimal {
        return visibles().compactMap({accountTotalValue($0, accountDescriptors: accountDescriptors, counter: true, credit: true, useAvailableBalance: useAvailableBalance)}).reduce(0, +)
    }
    
    public func totalValueFromCreditAccounts(accountDescriptors: [AccountDescriptorEntity], useAvailableBalance: Bool) -> Decimal? {
        let values = visibles().map({accountTotalValue($0, accountDescriptors: accountDescriptors, counter: false, credit: true, useAvailableBalance: useAvailableBalance)})
        guard !values.contains(nil) else { return nil }
        return values.compactMap({$0}).reduce(0, +)
    }
    
    private func getAmountNode(for product: AccountEntity) -> Decimal? {
        guard product.currentBalanceAmount?.dto.currency?.currencyType == .eur else { return nil }
        return product.currentBalanceAmount?.value ?? 0
    }
    
    private func accountTotalValue(_ account: AccountEntity, accountDescriptors: [AccountDescriptorEntity], counter: Bool, credit: Bool, useAvailableBalance: Bool) -> Decimal? {
        guard (credit && isCreditAccount(account, accountDescriptors: accountDescriptors)) || (!credit && !isCreditAccount(account, accountDescriptors: accountDescriptors)) else {
            return 0
        }
        switch useAvailableBalance {
        case true:
            if counter {
                if let balance = account.dto.countervalueAvailableNoAutAmount?.value {
                    return balance
                } else if let balance = account.dto.availableNoAutAmount?.value, let currency = account.dto.currency?.currencyType, currency == CoreCurrencyDefault.default {
                    return balance
                } else {
                    return 0
                }
            } else if let balance = account.dto.availableNoAutAmount?.value, let currency = account.dto.currency?.currencyType, currency == CoreCurrencyDefault.default {
                return balance
            }
        case false:
            if counter {
                if let balance = account.dto.countervalueCurrentBalanceAmount?.value {
                    return balance
                } else if let balance = account.dto.currentBalance?.value, let currency = account.dto.currency?.currencyType, currency == CoreCurrencyDefault.default {
                    return balance
                } else {
                    return 0
                }
            } else if let balance = account.dto.currentBalance?.value, let currency = account.dto.currency?.currencyType, currency == CoreCurrencyDefault.default {
                return balance
            }
        }
        return nil
    }
    
    private func isCreditAccount(_ account: AccountEntity, accountDescriptors: [AccountDescriptorEntity]) -> Bool {
        guard !accountDescriptors.isEmpty, let productSubtypeDTO = account.productSubtype else { return false }
        return accountDescriptors.contains(where: { $0.type == productSubtypeDTO.productType && $0.subType == productSubtypeDTO.productSubtype })
    }
}
