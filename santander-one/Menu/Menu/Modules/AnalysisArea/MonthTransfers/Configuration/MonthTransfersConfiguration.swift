//
//  MonthTransfersConfiguration.swift
//  Menu
//
//  Created by David Gálvez Alonso on 04/06/2020.
//

import CoreFoundationLib

final public class MonthTransfersConfiguration {
    
    var selectedTransfer: ExpenseType
    let allTransfers: TimeLineResultEntity
        
    public init(selectedTransfer: ExpenseType, allTransfers: TimeLineResultEntity) {
        self.selectedTransfer = selectedTransfer
        self.allTransfers = allTransfers
    }
}
