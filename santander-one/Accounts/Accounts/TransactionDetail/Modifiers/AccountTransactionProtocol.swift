//
//  AccountTransactionProtocol.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 23/3/21.
//

import Foundation

public protocol AccountTransactionProtocol {
    func getError() -> String
    var defaultNumberOfDateSearchFilter: Int { get }
    var disabledEasyPayAccount: Bool { get }
    var isEnabledConceptFilter: Bool { get }
    var isEnabledOperationTypeFilter: Bool { get }
    var isEnabledAmountRangeFilter: Bool { get }
    var isEnabledDateFilter: Bool { get }
}
