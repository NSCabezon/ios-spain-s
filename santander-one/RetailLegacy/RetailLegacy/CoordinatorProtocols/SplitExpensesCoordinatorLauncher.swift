//
//  SplitExpensesCoordinatorLauncher.swift
//  RetailLegacy
//
//  Created by Carlos Monfort Gómez on 20/4/21.
//

import Foundation
import CoreFoundationLib

public protocol SplitExpensesCoordinatorLauncher {
    func showSplitExpenses(_ operation: SplitableExpenseProtocol)
}
