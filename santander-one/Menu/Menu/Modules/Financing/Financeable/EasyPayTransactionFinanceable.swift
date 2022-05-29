//
//  EasyPayTransactionFinanceable.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 03/09/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

struct EasyPayTransactionFinanceable {
    let movement: AccountMovementRepresentable
    private let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    private let easyPay: AccountEasyPay?
    
    init(movement: AccountMovementRepresentable, offers: [PullOfferLocation: OfferEntity], easyPay: AccountEasyPay?) {
        self.movement = movement
        self.pullOfferCandidates = offers
        self.easyPay = easyPay
    }
    
    var amountValue: Decimal? {
        return Decimal(self.movement.amount)
    }
    
    var operationDate: Date {
        return self.movement.operationDate
    }
    
    var isEasyPayEnabled: Bool {
        switch easyPayFundableType {
        case .low where pullOfferCandidates.contains(location: FinanceableLocations.easyPayLowAmount.rawValue): return true
        case .high where pullOfferCandidates.contains(location: FinanceableLocations.easyPayHighAmount.rawValue): return true
        default: return false
        }
    }
    
    var easyPayFundableType: AccountEasyPayFundableType {
        guard let easyPay = self.easyPay,
              let amountEntity = self.amountEntity else {
                  return .notAllowed
              }
        return easyPayFundableType(for: amountEntity, operationDate: self.operationDate, accountEasyPay: easyPay)
    }
    
    var location: String? {
        guard self.isEasyPayEnabled else { return nil }
        switch easyPayFundableType {
        case .low: return FinanceableLocations.easyPayLowAmount.rawValue
        case .high: return FinanceableLocations.easyPayHighAmount.rawValue
        default: return nil
        }
    }
    
    var offer: OfferEntityViewModel? {
        guard let location = self.location else { return nil }
        return self.pullOfferCandidates.location(key: location).map({ OfferEntityViewModel(entity: $0.offer) })
    }
    
    var amountEntity: AmountEntity? {
        guard let amountEntity = self.movement.amountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        return amountEntity
    }
}

extension EasyPayTransactionFinanceable: AccountEasyPayChecker {}

extension EasyPayTransactionFinanceable: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(amountValue)
        hasher.combine(isEasyPayEnabled)
        hasher.combine(easyPayFundableType)
        hasher.combine(operationDate)
        hasher.combine(location)
    }
}

extension EasyPayTransactionFinanceable: Equatable {
    
    public static func == (lhs: EasyPayTransactionFinanceable, rhs: EasyPayTransactionFinanceable) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
