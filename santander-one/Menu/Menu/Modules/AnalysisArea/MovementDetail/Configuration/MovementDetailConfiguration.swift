//
//  MovementDetailConfiguration.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 24/06/2020.
//

import Foundation
import CoreFoundationLib

final public class MovementDetailConfiguration {
    public var detailMovements: MovementDetailViewModel?
    public var selectedIndex: Int = 0

    public init(debts: [TimeLineDebtEntity], selectedIndex: Int) {
        let movements = debts.map({ AnalysisMovementDetailEntity(description: $0.description, iban: $0.ibanEntity?.ibanPapel ?? "", amount: $0.amount, opDate: $0.fullDate) })
        detailMovements = MovementDetailViewModel(movements: movements, selected: movements[selectedIndex])
        self.selectedIndex = selectedIndex
    }
    
    public init(receipts: [TimeLineReceiptEntity], selectedIndex: Int) {
        let movements = receipts.map({AnalysisMovementDetailEntity(description: $0.merchant.name, iban: $0.ibanEntity?.ibanPapel ?? "", amount: $0.amount, opDate: $0.fullDate) })
        detailMovements = MovementDetailViewModel(movements: movements, selected: movements[selectedIndex])
        self.selectedIndex = selectedIndex
    }
    
    public init(subscription: [TimeLineSubscriptionEntity], selectedIndex: Int) {
        let movements = subscription.map({AnalysisMovementDetailEntity(description: $0.merchant.name, iban: $0.ibanEntity?.ibanPapel ?? "", amount: $0.amount, opDate: $0.fullDate) })
         detailMovements = MovementDetailViewModel(movements: movements, selected: movements[selectedIndex])
         self.selectedIndex = selectedIndex
     }
    
    public init(transfers: [TransferEmittedViewModel], selectedIndex: Int) {
        let movements = transfers.map({AnalysisMovementDetailEntity(description: $0.beneficiary ?? "", iban: $0.ibanEntity?.ibanPapel ?? "", amount: $0.transfer.amountEntity.value ?? 0.0, opDate: $0.transfer.executedDate!)})
        detailMovements = MovementDetailViewModel(movements: movements, selected: movements[selectedIndex])
        self.selectedIndex = selectedIndex
    }
}
