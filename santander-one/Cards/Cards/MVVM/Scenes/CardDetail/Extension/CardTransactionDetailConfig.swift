//
//  CardTransactionDetailConfigUse.swift
//  Cards
//
//  Created by Gloria Cano López on 8/4/22.
//
import CoreDomain

public struct CardTransactionDetailConfig {
    public let isEnabledMap: Bool
    public let isSplitExpensesEnabled: Bool
    public let enableEasyPayCards: Bool
    public let isEasyPayClassicEnabled: Bool
    
    init(isEnabledMap: Bool, isSplitExpensesEnabled: Bool, enableEasyPayCards: Bool, isEasyPayClassicEnabled: Bool) {
        self.isEnabledMap = isEnabledMap
        self.isSplitExpensesEnabled = isSplitExpensesEnabled
        self.enableEasyPayCards = enableEasyPayCards
        self.isEasyPayClassicEnabled = isEasyPayClassicEnabled
    }
}

extension CardTransactionDetailConfig: CardTransactionDetailConfigRepresentable { }
