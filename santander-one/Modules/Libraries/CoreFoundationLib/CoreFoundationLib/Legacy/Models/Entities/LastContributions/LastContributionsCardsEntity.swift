//
//  LastContributionsCardsEntity.swift
//  Models
//
//  Created by Ignacio González Miró on 03/09/2020.
//

import Foundation
import SANLegacyLibrary
import CoreDomain

public final class LastContributionsCardsEntity {
    public var cardRepresentable: CardRepresentable
    // swiftlint:disable force_cast
    public var dto: CardDTO {
        precondition((cardRepresentable as? CardDTO) != nil)
        return cardRepresentable as! CardDTO
    }
    // swiftlint:enable force_cast
    public var changePaymentsDTO: ChangePaymentDTO?
    public let cardType: CardDOType?
    public var cardBalanceDTO: CardBalanceDTO?
    public var urlImg: String

    public init(_ cardRepresentable: CardRepresentable) {
        self.cardRepresentable = cardRepresentable
        self.cardType = CardDOType(cardRepresentable)
        self.urlImg = ""
    }
    
    public init(_ cardRepresentable: CardRepresentable, changePaymentsDTO: ChangePaymentDTO?, cardBalanceDTO: CardBalanceDTO?, urlImage: String) {
        self.cardRepresentable = cardRepresentable
        self.changePaymentsDTO = changePaymentsDTO
        self.cardBalanceDTO = cardBalanceDTO
        self.cardType = CardDOType(cardRepresentable)
        self.urlImg = urlImage
    }
    
    public var title: String {
        return cardRepresentable.alias?.camelCasedString ?? ""
    }
    
    public var iban: String {
        let title = cardRepresentable.cardTypeDescription ?? ""
        guard let PAN = cardRepresentable.formattedPAN else { return "****" }
        let lastFourDigits = PAN.substring(PAN.count - 4) ?? "*"
        return title + " " + "*" + lastFourDigits
    }
    
    public var amount: AmountEntity? {
        switch cardType {
        case .debit:
            return nil
        case .credit:
            return currentBalance
        case .prepaid:
            return availableAmount
        case .none:
            return nil
        }
    }
    
    public var currentBalance: AmountEntity {
        guard let amount = cardBalanceDTO?.currentBalance else {
            return AmountEntity(value: 0.0)
        }
        return AmountEntity(amount)
    }

    public var availableAmount: AmountEntity {
        guard let amount = cardBalanceDTO?.availableAmount else {
            return AmountEntity(value: 0.0)
        }
        return AmountEntity(amount)
    }
    
    public func amountDecimalToAmountEntity(_ value: Decimal) -> AmountEntity {
        return AmountEntity(value: value)
    }
    
    public var currentPaymentType: PaymentMethodType? {
        return self.changePaymentsDTO?.currentPaymentMethod
    }
    
    public var feeDetail: String? {
        return self.changePaymentsDTO?.currentPaymentMethodDescription
    }
}
