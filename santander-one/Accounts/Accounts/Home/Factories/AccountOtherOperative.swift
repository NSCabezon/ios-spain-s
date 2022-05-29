//
//  AccountOtherOperative.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/5/21.
//
import CoreFoundationLib
import Foundation

final class AccountOtherOperativeActionData {
    private let entity: AccountEntity
    private let offers: [PullOfferLocation: OfferEntity]
    private let action: ((AccountActionType, AccountEntity) -> Void)?
    
    init(entity: AccountEntity, offers: [PullOfferLocation: OfferEntity], action: ((AccountActionType, AccountEntity) -> Void)?) {
        self.entity = entity
        self.offers = offers
        self.action = action
    }
    
    func getAccountEntity() -> AccountEntity {
        return self.entity
    }
    
    func getOffers() -> [PullOfferLocation: OfferEntity] {
        return offers
    }
    
    func getAction() -> ((AccountActionType, AccountEntity) -> Void)? {
        return self.action
    }
}
