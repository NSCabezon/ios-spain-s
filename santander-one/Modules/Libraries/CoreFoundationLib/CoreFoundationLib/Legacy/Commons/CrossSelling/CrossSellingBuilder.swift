//
//  CrossSellingBuilder.swift
//  Commons
//
//  Created by Margaret López Calderón on 25/8/21.
//

import Foundation

public final class CrossSellingBuilder {
    private let itemsCrossSelling: [CrossSellingRepresentable]
    private let transactionDescription: String?
    private let transactionAmount: Decimal?
    private let crossSellingValues: CrossSellingValues
    
    public init(itemsCrossSelling: [CrossSellingRepresentable],
                transaction: String?,
                amount: Decimal?,
                crossSellingValues: CrossSellingValues) {
        self.itemsCrossSelling = itemsCrossSelling
        self.transactionDescription = transaction
        self.transactionAmount = amount
        self.crossSellingValues = crossSellingValues
    }
    
    public func getCrossSelling<T: CrossSellingRepresentable>() -> T? {
        return itemsCrossSelling.first { crossSelling in
            let globalValidation = validateCommon(crossSelling)
            let customValidation = validateForCustomType(crossSelling)
            return globalValidation && customValidation
        } as? T
    }
}

private extension CrossSellingBuilder {
    func validateCommon(_ crossSelling: CrossSellingRepresentable) -> Bool {
        var tagsOk = crossSelling.tagsCrossSelling.isEmpty
        var amountOk = crossSelling.amountCrossSelling == nil
        if !tagsOk, let description = transactionDescription,
           crossSelling.tagsCrossSelling.contains(where: { description.lowercased().contains($0.lowercased()) }) {
            tagsOk = true
        }
        if !amountOk, let amountCrossSelling = crossSelling.amountCrossSelling, let transactionAmount = transactionAmount {
            if amountCrossSelling >= 0 {
                amountOk = transactionAmount >= amountCrossSelling
            } else {
                amountOk = transactionAmount <= amountCrossSelling
            }
        }
        return tagsOk && amountOk
    }
    
    func validateForCustomType(_ crossSelling: CrossSellingRepresentable) -> Bool {
        var customTypeValidation = false
        switch crossSelling.crossSellingType {
        case .accounts:
            let methodResult = accountsCustomValidation(crossSelling)
            customTypeValidation = methodResult
        case .cards:
            let methodResult = cardsCustomValidation(crossSelling)
            customTypeValidation = methodResult
        }
        return customTypeValidation
    }
    
    func cardsCustomValidation(_ crossSelling: CrossSellingRepresentable) -> Bool {
        guard crossSelling.cardTypeCrossSelling != nil && crossSelling.cardTypeCrossSelling?.count != 0,
                let typeDictionary = crossSelling.cardTypeCrossSelling,
                let cardValues = crossSellingValues.cardValues else {
            return true
        }
        let debit = typeDictionary[CrossSellingConstants.isDebit] == CrossSellingConstants.trueValue
        let credit = typeDictionary[CrossSellingConstants.isCredit] == CrossSellingConstants.trueValue
        let prepaid = typeDictionary[CrossSellingConstants.isPrepaid] == CrossSellingConstants.trueValue
        guard debit == cardValues.isDebit && debit ||
              credit == cardValues.isCredit && credit ||
              prepaid == cardValues.isPrepaid && prepaid
        else {
            return false
        }
        return true
    }
    
    func accountsCustomValidation(_ crossSelling: CrossSellingRepresentable) -> Bool {
        guard let amountAccount = crossSelling.accountAmountCrossSelling else {
            return true
        }
        let availableAmountAccount = crossSellingValues.accountValues?.availableAmount ?? 0
        guard availableAmountAccount.isSignMinus else {
            let isCrossSelling = availableAmountAccount >= amountAccount
            return isCrossSelling
        }
        let isCrossSelling = availableAmountAccount <= amountAccount
        return isCrossSelling
    }
}

struct CrossSellingConstants {
    static let isDebit = "isDebit"
    static let isCredit = "isCredit"
    static let isPrepaid = "isPrepaid"
    static let trueValue = "true"
}

public struct CrossSellingValues {
    public let cardValues: CardValues?
    public let accountValues: AccountValues?
    public init(cardValues: CardValues? = nil, accountValues: AccountValues? = nil) {
        self.cardValues = cardValues
        self.accountValues = accountValues
    }
}

public struct CardValues {
    public let isDebit: Bool
    public let isCredit: Bool
    public let isPrepaid: Bool
    public init(isDebit: Bool, isCredit: Bool, isPrepaid: Bool) {
        self.isDebit = isDebit
        self.isCredit = isCredit
        self.isPrepaid = isPrepaid
    }
}

public struct AccountValues {
    public let availableAmount: Decimal
    public init(_ availableAmount: Decimal) {
        self.availableAmount = availableAmount
    }
}
