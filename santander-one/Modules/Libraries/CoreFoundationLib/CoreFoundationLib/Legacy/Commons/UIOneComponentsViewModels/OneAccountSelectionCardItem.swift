//
//  OneAccountSelectionCardItem.swift
//  Models
//
//  Created by David Gálvez Alonso on 01/09/2021.
//

import CoreDomain

public final class OneAccountSelectionCardItem {
    
    public let account: AccountRepresentable
    public var cardStatus: CardStatus
    public let helperText: String
    public let accessibilityOfView: String
    private let amountToShow: SendMoneyAmountToShow
    private let numberFormater: AccountNumberFormatterProtocol?
    public let accessibilitySuffix: String?
    
    public init(account: AccountRepresentable,
                cardStatus: OneAccountSelectionCardItem.CardStatus,
                helperText: String = "account_label_transferBalance",
                accessibilityOfView: String,
                amountToShow: SendMoneyAmountToShow = .currentBalance,
                accessibilitySuffix: String? = nil,
                numberFormater: AccountNumberFormatterProtocol?) {
        self.account = account
        self.cardStatus = cardStatus
        self.helperText = helperText
        self.accessibilityOfView = accessibilityOfView
        self.amountToShow = amountToShow
        self.accessibilitySuffix = accessibilitySuffix
        self.numberFormater = numberFormater
    }
    
    public var title: String {
        return self.account.alias?.camelCasedString ?? ""
    }
    
    public var description: String {
        guard let numberFormat = numberFormater else {
            return self.account.getIBANPapel
        }
        return numberFormat.accountNumberFormat(self.account)
    }
    
    public var amountRepresentable: AmountRepresentable? {
        switch self.amountToShow {
        case .available: return self.account.availableAmount
        case .currentBalance: return self.account.currentBalanceRepresentable
        }
    }
    
    public enum CardStatus {
        case inactive
        case selected
        case favourite
        case hidden
    }
}
