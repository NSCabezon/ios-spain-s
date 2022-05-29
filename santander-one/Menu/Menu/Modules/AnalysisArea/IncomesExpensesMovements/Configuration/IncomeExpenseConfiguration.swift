//
//  IncomeXpenseConfiguration.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 09/06/2020.
//

import CoreFoundationLib
import CoreDomain

final public class IncomeExpenseConfiguration {
    public var selectedMovementType: AccountMovementsType
    public var selectedMonthlyBalanceRepresentable: MonthlyBalanceRepresentable
    
    public init(selectedMovementType: AccountMovementsType, pfmMonth: MonthlyBalanceRepresentable) {
        self.selectedMovementType = selectedMovementType
        self.selectedMonthlyBalanceRepresentable = pfmMonth
    }
}
