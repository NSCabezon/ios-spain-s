//
//  SCATransactionParams.swift
//  Account
//
//  Created by Jose Javier Montes Romero on 2/9/21.
//

import Foundation
import CoreFoundationLib

public struct SCATransactionParams {
    public let account: AccountEntity
    public let pagination: PaginationEntity?
    public let scaState: ScaState?
    public let filters: TransactionFiltersEntity?
    public let filtersIsShown: Bool?
}
