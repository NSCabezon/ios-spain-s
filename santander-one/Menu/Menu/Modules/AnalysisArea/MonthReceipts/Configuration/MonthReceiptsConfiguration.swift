//
//  MonthReceiptsConfiguration.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/06/2020.
//

import CoreFoundationLib

final public class MonthReceiptsConfiguration {
    
    var selectedReceipt: ExpenseType
    let allReceipts: TimeLineResultEntity
        
    public init(selectedReceipt: ExpenseType, allReceipts: TimeLineResultEntity) {
        self.selectedReceipt = selectedReceipt
        self.allReceipts = allReceipts
    }
}
