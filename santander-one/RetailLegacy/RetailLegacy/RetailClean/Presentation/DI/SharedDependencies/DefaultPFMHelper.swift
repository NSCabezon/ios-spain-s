//
//  DefaultPFMHelper.swift
//  RetailLegacy
//
//  Created by José Carlos Estela Anguita on 4/2/22.
//

import Foundation
import CoreFoundationLib
import CoreFoundationLib

public final class DefaultPFMHelper: PfmHelperProtocol {
    
    public init() {
        
    }
    
    public func getMovementsFor(userId: String, date: Date, account: AccountEntity) -> [AccountTransactionEntity] {
        return []
    }
    
    public func getMovementsFor(userId: String, matches: String, account: AccountEntity, limit: Int, date: Date) -> [AccountTransactionEntity] {
        return []
    }
    public func getMovementsFor(userId: String, matches: String, card: CardEntity, limit: Int, date: Date) -> [CardTransactionEntity] {
        return []
    }
    
    public func getLastMovementsFor(userId: String, card: CardEntity) -> [CardTransactionEntity] {
        return []
    }
    
    public func getLastMovementsFor(userId: String, card: CardEntity, startDate: Date, endDate: Date) -> [CardTransactionEntity] {
        return []
    }
    
    public func getLastMovementsFor(userId: String, card: CardEntity, searchText: String, fromDate: Date, toDate: Date?) -> [CardTransactionEntity] {
        return []
    }
    
    public func getUnreadMovementsFor(userId: String, date: Date, account: AccountEntity) -> Int? {
        return nil
    }
    
    public func getUnreadMovementsFor(userId: String, date: Date, card: CardEntity) -> Int? {
        return nil
    }
    
    public func cardExpensesCalculationTransaction(userId: String, card: CardEntity) -> AmountEntity {
        return AmountEntity(value: 0)
    }
    
    public func setReadMovements(for userId: String, account: AccountEntity) {
        
    }
    
    public func setReadMovements(for userId: String, card: CardEntity) {
        
    }
    
    public func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String, toDate: Date?) -> [AccountTransactionEntity] {
        return []
    }
    
    public func getMovementsFor(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity] {
        return []
    }
    
    public func getUnreadCardMovementsFor(userId: String, startDate: Date, card: CardEntity, limit: Int?) -> [CardTransactionEntity] {
        return []
    }
    
    public func getUnreadAccountMovementsFor(userId: String, startDate: Date, account: AccountEntity, limit: Int?) -> [AccountTransactionEntity] {
        return []
    }
    
    public func execute() {
        
    }
    
    public func finishSession(_ reason: SessionFinishedReason?) {
        
    }
}
